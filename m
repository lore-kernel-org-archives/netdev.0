From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Sat, 9 Jan 2010 13:28:30 +0100
Message-ID: <20100109122830.GA4386@del.dom.local>
References: <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local>
 <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local>
 <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local>
 <4B47A81B.5040601@majjas.com>
 <4B4809EF.1070609@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:53004 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950Ab0AIM2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 07:28:36 -0500
Content-Disposition: inline
In-Reply-To: <4B4809EF.1070609@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2010 at 11:45:35PM -0500, Michael Breuer wrote:
> On 1/8/2010 4:48 PM, Michael Breuer wrote:
> >On 1/8/2010 4:29 PM, Jarek Poplawski wrote:
> >...
> >>BTW, don't hurry with that yet, but in the next test, please try
> >>alternative 2 again (i.e. with MMAP + no DMAR + disable_msi).
> >>
> >Will do - still up from yesterday... no more dropped packets...
> >none of the dns errors either. To be expected I suppose as long as
> >I'm trying to sniff it. Assuming no immediate erorrs with alt2, no
> >DMAR + disable_msi I'll report back after it's been up for a
> >while.
> >-- 
> Ok - ran alt1 and alt2, both with MMAP, no DMAR and disable_msi.
> Both seem to behave similarly. No logged errors;

Ok - since alt2 introduces less changes and is acked by Stephen
already, I'll resend it with your "Tested-by" in a new thread to clear
things a bit.

> large numbers of dropped RX packets.

You might try some tweaking with another sky2 parameter "copybreak"
or even editing its "NAPI_WEIGHT" variable.

> One odd thing: when driving every sort of
> traffic through, I was able to hose the client adapter (win7)
> repeatedly by runnnig the win7 backup and connecting Windows Media
> Player to a Mediatomb stream while also running a remote X11
> session. Looks like the SSDP traffic that occurs at the same time as
> the SMB traffic and X11 traffic takes out the adapter on Win7 -
> Nforce.
> Reran with msi enabled, MMAP and no DMAR. Also no errors; much
> faster, and the Win7 side survives the same conditions that don't
> work when msi is disabled. Doesn't make sense to me, but it is what
> it is.
> 
> Going to leave this up for a while and see if things remain functional.

It looks like DMAR is the main candidate for a new linux-kernel@ or
bugzilla bug report. You should also consider reporting these ipv6
problems, especially if you think they can trigger TX timeouts. (In
both cases it would be good to try current mainline first, when you
get it workable.)

Thanks,
Jarek P.
