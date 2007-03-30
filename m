From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8284] New: IPsec anti-replay window management
 flaw
Date: Fri, 30 Mar 2007 01:14:50 -0700
Message-ID: <20070330011450.f981a8ca.akpm@linux-foundation.org>
References: <200703300806.l2U86HLU019078@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>,
	didier.schrapf@alcatelaleniaspace.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:55196 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945943AbXC3IPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 04:15:00 -0400
In-Reply-To: <200703300806.l2U86HLU019078@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Mar 2007 01:06:17 -0700 bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8284
> 
>            Summary: IPsec anti-replay window management flaw
>     Kernel Version: 2.6.20.4
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: didier.schrapf@alcatelaleniaspace.com
> 
> 
> The IPsec ESP/AH anti-replay window size is configurable, 64 being the value 
> recommended by RFC 2406.
> Linux kernels use a 32 bit bitmap to check whether a sequence number has 
> already been received.
> 
> When a packet is received, if its seq is lower than the greatest received seq,
> and if the difference is greater than 32, the check doesn't work.
> This constitutes a security flaw.
> 
> The faulty code is in net/xfrm/xfrm-state.c, functions xfrm_replay_check() and 
> xfrm_replay_advance().
