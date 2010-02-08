From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC]: xfrm by mark
Date: Mon, 08 Feb 2010 10:28:34 -0500
Message-ID: <1265642914.3688.71.camel@bigi>
References: <1265567522.3688.27.camel@bigi>  <4B701204.6000106@trash.net>
	 <1265641110.3688.45.camel@bigi>  <4B702711.6080800@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:63355 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364Ab0BHP2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 10:28:40 -0500
Received: by bwz23 with SMTP id 23so1228509bwz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 07:28:39 -0800 (PST)
In-Reply-To: <4B702711.6080800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-08 at 16:00 +0100, Patrick McHardy wrote:

> I'd prefer masks since the mark size is pretty small and its already
> quite complicated to fit everything in 32 bit in complex setups.
> We also support masks everywhere else (I believe) for mark values
> nowadays.

I could still use the mask also as it is consistently 
being used today i.e (mark & x->mask) == x->mark
the only challenge i can think of is operational. How
do you see me activating the use of these marks? The setups
i see:

-By default if i use pfkey or old iproute2 i can have both
mask and val as 0. no problem there..
-If i was to insert table entries with say mark val 4 and mask 
of 0, that would continue to work since mark is ignored.
-if at some later point i want to use this mark 4, do i just change
the mask? That may not scale well if you have a gazillion entries.
If i used a sysctl all i would do is just turn on the
syctl and the check becomes:
syctl_use_mark && ((mark & x->mask) == x->mark)

Thoughts?

cheers,
jamal

