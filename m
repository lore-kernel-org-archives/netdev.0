From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: Re: [PATCH net] be2net: Increase skb headroom size to 256 bytes
Date: Wed, 21 Dec 2016 13:43:38 +0530
Message-ID: <CAHHeUGWmcDHSiPWaOiRPjjN79Ba5c+43ku=d9bWwp92QGvYdyQ@mail.gmail.com>
References: <20161220151430.11115-1-suresh.reddy@broadcom.com> <20161220.143032.511618714729371345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Suresh Kumar Reddy Reddygari <suresh.reddy@broadcom.com>,
        netdev@vger.kernel.org,
        Kalesh Anakkur Purayil <kalesh-anakkur.purayil@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36531 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753370AbcLUINk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 03:13:40 -0500
Received: by mail-wm0-f54.google.com with SMTP id g23so141317478wme.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 00:13:39 -0800 (PST)
In-Reply-To: <20161220.143032.511618714729371345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 1:00 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Suresh Reddy <suresh.reddy@broadcom.com>
> Date: Tue, 20 Dec 2016 10:14:30 -0500
>
> > From: Kalesh A P <kalesh-anakkur.purayil@broadcom.com>
> >
> > The driver currently allocates 128 bytes of skb headroom.
> > This was found to be insufficient with some configurations
> > like Geneve tunnels, which resulted in skb head reallocations.
> >
> > Increase the headroom to 256 bytes to fix this.
> >
> > Signed-off-by: Kalesh A P <kalesh-anakkur.purayil@broadcom.com>
> > Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
>
> Adding 128 bytes of headroom just for geneve seems excessive.
>
> Do you really need to add that much?

Hi David,

With geneve, there's a fixed 8 byte header followed by a variable
options header of max length 256 bytes. And with vlan+ipv6 combination
we could run out of 128 bytes headroom even with just the fixed geveve
header (+ outer and inner eth/ipv6/transport headers).

Thanks,
-Harsha
