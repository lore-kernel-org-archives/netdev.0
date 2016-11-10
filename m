From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 4/7] vxlan: improve vxlan route lookup checks.
Date: Thu, 10 Nov 2016 10:10:25 -0800
Message-ID: <CAOrHB_DPWiGah9vADm=SXXnWkiDcvsHdmy3RQ6f7ntjmjZOeDg@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-5-git-send-email-pshelar@ovn.org> <20161109174138.410b4385@griffin>
 <CAOrHB_BwcJ0K3YcqPrVkKxFjWX9DFT1NjS3BbrcNtKQ_p_y44w@mail.gmail.com> <20161110105639.6e8b70f7@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:49795 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753655AbcKJSK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 13:10:59 -0500
Received: from mfilter31-d.gandi.net (mfilter31-d.gandi.net [217.70.178.162])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id F1AA31720BC
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 19:10:57 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter31-d.gandi.net (mfilter31-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id ib5Cm5c2iWem for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 19:10:26 +0100 (CET)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 97AE21720BD
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 19:10:26 +0100 (CET)
Received: by mail-it0-f49.google.com with SMTP id u205so59040709itc.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 10:10:26 -0800 (PST)
In-Reply-To: <20161110105639.6e8b70f7@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 1:56 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 9 Nov 2016 19:34:06 -0800, Pravin Shelar wrote:
>> Why it would not help in non-ovs vxlan egress path? It avoids checking
>> (if condition) for device loop.
>
> I may be missing something but I count the same number of conditions
> for each packet, they're just at a different place after the patch.
>
I am specifically talking about cached routes. If the dst entry is
cached, this patch avoids checking for device loop.

> E.g. for IPv4, the "if (!sock4)" is moved from vxlan_xmit_one into
> vxlan_get_route and the "rt" error handling stays logically the same
> (three if conditions in the non-error path) but is moved into
> vxlan_get_route. Similarly for IPv6.
>
>  Jiri
