From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v4 net-next 07/10] openvswitch: Inherit master's labels.
Date: Thu, 9 Feb 2017 13:40:54 -0800
Message-ID: <CAPWQB7H-URWDzAL_nyzEj3x-=uCe2XnJs=85NmRgpLn+fhgs2w@mail.gmail.com>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org> <1486668121-45709-8-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:45473 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752650AbdBIVoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:44:38 -0500
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 0E5A24B6251
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:42:19 +0100 (CET)
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id D666F1720A3
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:41:17 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id DYUpsRht_CIY for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 22:41:16 +0100 (CET)
Received: from mail-qt0-f178.google.com (mail-qt0-f178.google.com [209.85.216.178])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 5F4A11720A5
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:41:15 +0100 (CET)
Received: by mail-qt0-f178.google.com with SMTP id w20so17313140qtb.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 13:41:15 -0800 (PST)
In-Reply-To: <1486668121-45709-8-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 February 2017 at 11:21, Jarno Rajahalme <jarno@ovn.org> wrote:
> We avoid calling into nf_conntrack_in() for expected connections, as
> that would remove the expectation that we want to stick around until
> we are ready to commit the connection.  Instead, we do a lookup in the
> expectation table directly.  However, after a successful expectation
> lookup we have set the flow key label field from the master
> connection, whereas nf_conntrack_in() does not do this.  This leads to
> master's labels being inherited after an expectation lookup, but those
> labels not being inherited after the corresponding conntrack action
> with a commit flag.
>
> This patch resolves the problem by changing the commit code path to
> also inherit the master's labels to the expected connection.
> Resolving this conflict in favor of inheriting the labels allows more
> information be passed from the master connection to related
> connections, which would otherwise be much harder if the 32 bits in
> the connmark are not enough.  Labels can still be set explicitly, so
> this change only affects the default values of the labels in presense
> of a master connection.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
