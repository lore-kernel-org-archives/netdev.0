From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 11:14:42 -0500
Message-ID: <20120216161442.GA10857@elliptictech.com>
References: <20120215163748.GA3998@elliptictech.com>
 <20120215224122.GA31463@electric-eye.fr.zoreil.com>
 <20120215233408.GA8389@elliptictech.com>
 <1329365963.2469.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.scalarmail.ca ([98.158.95.75]:18805 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751797Ab2BPQOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 11:14:49 -0500
Content-Disposition: inline
In-Reply-To: <1329365963.2469.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-02-16 05:19 +0100, Eric Dumazet wrote:
> 1) Are you using SLUB, SLAB, or SLOB ?

SLUB.

> 2) Problem with MTU=9000 is that frames span several 4K pages.
> 
> Maybe some versions of r8169 hardware have problems with that ...

Could be, but probably not the whole story.  I tested some >4k MTU values
(all with 60K packets here because it failed more reliably than 30K).
6500 byte MTU appears to work OK (<1% loss).  7500 fails (>99% loss).
A largish range of MTU settings inbetween achieve a roughly 50% loss
rate.

The corruption is not always as significant as the original trace: some
of my tests had all the fragments correct but a mere two bytes of payload
were zero (resulting in the reassembled datagram being dropped due to a
checksum failure).

Recall that the original trace also had this "two bytes zeroed" problem
in the second fragment, in addition to all its other problems.

Cheers,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
