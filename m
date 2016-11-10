From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Thu, 10 Nov 2016 11:21:19 -0800
Message-ID: <CAOrHB_AGV4x4G4QYFAaWNYgckvkDAS-prp65CgXfTqB4KoxHTw@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-3-git-send-email-pshelar@ovn.org> <20161109171018.69d08ff9@griffin>
 <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com>
 <20161110104703.7386ab29@griffin> <CAOrHB_BdYpCpjrzHmNmEkvhXk7u6Gb_1aRyggeCrsL0Jx1nkvw@mail.gmail.com>
 <20161110193347.0e81d68b@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:47768 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932259AbcKJTV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 14:21:27 -0500
Received: from mfilter39-d.gandi.net (mfilter39-d.gandi.net [217.70.178.170])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id CE8C4A80C6
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 20:21:25 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter39-d.gandi.net (mfilter39-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id HGOB-p0SVKlR for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 20:21:24 +0100 (CET)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 450E1A80CD
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 20:21:24 +0100 (CET)
Received: by mail-it0-f41.google.com with SMTP id e187so281414026itc.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 11:21:24 -0800 (PST)
In-Reply-To: <20161110193347.0e81d68b@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 10:33 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Thu, 10 Nov 2016 10:10:09 -0800, Pravin Shelar wrote:
>> I wanted to do same, that is free dst and skb in caller function. But
>> that would need more changes due to discrepancy in IPv4 udp-tunnel and
>> IPv6 udp-tunnel api. IPv4 works on route entry and IPv6 needs dst
>> entry. so If caller frees dst-entry then I need additional variable to
>> keep track of dst entry which is what I am trying to avoid.
>
> Is additional variable really that bad? It's likely to be optimized by
> the compiler and it will lead to less surprises. You obviously caught
> me during review :-)
>
One additional variable is not bad but look at what has happened in
vxlan_xmit_one(). There are already more than 20 variables defined. It
is hard to read code in this case.
anyways I can add another variable to the function. I do not feel that
strongly about this.
