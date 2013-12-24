From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vxlan: distribute vxlan tunneled traffic
 across multiple TXQs
Date: Tue, 24 Dec 2013 15:05:43 -0800
Message-ID: <20131224150543.66581c13@nehalam.linuxnetplumber.net>
References: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
	<20131223112854.572b11aa@nehalam.linuxnetplumber.net>
	<1387910346.12212.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sathya Perla <sathya.perla@emulex.com>, netdev@vger.kernel.org,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:55347 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab3LXXFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 18:05:46 -0500
Received: by mail-pa0-f45.google.com with SMTP id fb1so6901215pad.4
        for <netdev@vger.kernel.org>; Tue, 24 Dec 2013 15:05:45 -0800 (PST)
In-Reply-To: <1387910346.12212.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Dec 2013 10:39:06 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2013-12-23 at 11:28 -0800, Stephen Hemminger wrote:
> 
> > The idea is good, but without the destructor there is nothing to keep
> > the UDP socket from being destroyed while packet is being sent on another
> > CPU.
> 
> I see no requirement of holding a reference on the vxlan UDP socket in
> transmit path.
> 
> At the time vxlan_set_owner() is called, nothing requires access to the
> socket anymore. If you believe its needed, then its already too late.
> 
> Sathya, your patch is a step in the right direction, but the skb_clone()
> thing should be done a bit differently.
> 
> The trick would be to avoid the skb_clone() for the last
> vxlan_xmit_one() call.
> 

That code was cloned from L2TP, I assumed that that it was required
to hold reference when calling UDP, since that is what socket layer does.
