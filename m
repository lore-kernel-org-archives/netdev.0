From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] div64_64 support
Date: Mon, 5 Mar 2007 15:57:14 -0800
Message-ID: <20070305155714.3abe1b5e@freekitty>
References: <20070223170527.4ca695b2@freekitty>
	<Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
	<20070226143127.5c74bec9@freekitty>
	<p73slcnawh3.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42067 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933115AbXCEX53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 18:57:29 -0500
In-Reply-To: <p73slcnawh3.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03 Mar 2007 03:31:52 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> writes:
> 
> > Here is another way to handle the 64 bit divide case.
> > It allows full 64 bit divide by adding the support routine
> > GCC needs.
> 
> Not supplying that was intentional by Linus so that people
> think twice (or more often) before they using such expensive
> operations. A plain / looks too innocent.
> 
> Is it really needed by CUBIC anyways?  It uses it for getting
> the cubic root, but the algorithm recommended by Hacker's Delight
> (great book) doesn't use any divisions at all. Probably better 
> to use a better algorithm without divisions.
> 

I tried the code from Hacker's Delight.
It is cool, but performance is CPU (and data) dependent:

Average # of usecs per operation:

		Hacker		Newton
Pentium 3	68.6	<	90.4
T2050		98.6	>	92.0
U1400		450	>	415
Xeon		70 	<	90
Xeon (newer)	71	<	78

EM64T		21.8	<	24.6
AMD64		23.4	<	32.0

It might be worth the change for code size reduction though.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
