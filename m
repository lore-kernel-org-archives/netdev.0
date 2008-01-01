From: Benjamin LaHaise <bcrl@kvack.org>
Subject: announce: Babylon PPP (scalable L2TP) 2.0 beta 1
Date: Tue, 1 Jan 2008 18:00:42 -0500
Message-ID: <20080101230042.GH13328@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:52989 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754902AbYAAXBC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2008 18:01:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

This is an announcement for a new beta release of a decently scalable L2TP 
stack for Linux.  It is based off of the Babylon PPP stack created by 
SpellCaster back in the '98-'00 timeframe.  Right now there are lots of 
rough edges (especially in terms of documentation), but it works well enough 
for many purposes.

The main difference between the Babylon PPP stack and pppd is that the 
Babylon code uses a single process for controlling all PPP sessions 
established throughout the system, which uses significantly less memory 
and processing power per connection.  Practically speaking, a mid range 
system can terminate thousands of sessions without breaking a sweat.

Features
	- entirely GPLed
	- can terminate thousands of sessions
	- includes kernel mode multihop for L2TP
	- can act as an LAC or LNS
	- has gigawords accounting for sessions
	- includes Radius client support
	- already in use to terminate real L2TP traffic for 2 ISPs.
	- works on x86/x86-64.  Not expected to work on architectures where 
	unaligned memory accesses are problematic.

Non-Features
	- Uses its own kernel mode PPP stack for L2TP and PPPoE.  The 
	exact direction for this is open to discussions, but will require 
	lots of work to address the scalability issues.
	- PPPoE support is not well integrated at present.  It works for 
	dial out (kernel mode via drivers/pppoe/pppoed and kernel/bab_pppoe.o) 
	or PPPoE->L2TP conversion (userspace), but not incoming calls as-is.
	- device nodes are still a work in progress
	- packaging needs improvement
	- the kernel code is not at all ready for merging as it needs fairly 
	major cleanup in several areas

The README.l2tp file gives a rough description of what is needed to get 
things going on recent 2.6 kernels, but I've only been testing 2.6.22.5 
for this release.  Questions/comments are appreciated.  The source can 
be had via git clone http://www.kvack.org/~bcrl/babylon.git/.git .  Cheers,

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
