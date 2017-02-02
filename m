From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next ovs clone action 3/3] openvswitch: kernel datapath
 clone action
Date: Wed, 1 Feb 2017 18:30:30 -0800
Message-ID: <CAOrHB_D5_4+3MZ6yuU1FMJkjFO-Gv2fav55dg3=hZt8cB+g6SQ@mail.gmail.com>
References: <1485881247-6683-1-git-send-email-azhou@ovn.org> <1485881247-6683-3-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:52219 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdBBCaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:30:35 -0500
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 1F925FB881
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 03:30:33 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id xuj35IGapEDO for <netdev@vger.kernel.org>;
        Thu,  2 Feb 2017 03:30:31 +0100 (CET)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id B1F4DFB87D
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 03:30:31 +0100 (CET)
Received: by mail-io0-f177.google.com with SMTP id v96so75738919ioi.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 18:30:31 -0800 (PST)
In-Reply-To: <1485881247-6683-3-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 8:47 AM, Andy Zhou <azhou@ovn.org> wrote:
> Add 'clone' kernel datapath support. In case the actions within clone
> do not modify the current flow, the actions are executed without
> making a copy of current key before execution. This analysis is
> done once per flow installation.
>
> On the other hand, in case the actions within clone may modify
> current flow key, a key has to be copied. In case the percpu
> 'flow_keys' is available for the next 'exec_actions_level', the clone
> actions will be executed without using the deferred fifo. Otherwise,
> deferred fifo is used this clone action.
>

I think we can use sample action to clone packet and apply
optimization to sample action. That will allow greater use of existing
action without additional complexity.

Thanks,
Pravin.
