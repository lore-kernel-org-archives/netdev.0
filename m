From: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Subject: AW: RFC: replace packets already in queue
Date: Fri, 29 Jun 2012 08:46:32 +0000
Message-ID: <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
 <4FEC854E.8080603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailguard.fkie.fraunhofer.de ([128.7.3.5]:43075 "EHLO
	a.mx.fkie.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab2F2Iqg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 04:46:36 -0400
In-Reply-To: <4FEC854E.8080603@hp.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rick Jones,

> You might want to try the recent "codel" additions to the stack.  They
> seek to keep the size of queues more manageable while still allowing
> the occasional burst.
Thank you for your hint. This is surly a needful solution in normal network, but this didn't help us:
We are working with very heterogeneous networks:
Internal: 100MBit and more.
Extern: 9,6*K*Bit and LESS(*), and shared, and...
A few other information: wireless (higher packet loss rate), medium access time > 100ms, RTT (standard ping) with IDLE network: 1,5 *seconds*, RTT with network load: minutes(!), and so on. Just very shocking..

TCP isn't usable over such a link. So we are only sending UDP. The codel didn't help us, as codel addresses the flow speed. It's dropping "randomly" (I know it's not random in the lower level, but it's random from the application's perspective) packets. 

I'm addressing the amount of information: Trying to reduce it intelligently by REPLACING old packets with new ones.. Surely - the application must handle this. But in such a network a administrator have to configure the queues and he knows the applications.
In one private mail someone guesses that we are making VoIP. No - we just want to send status information (e.g. sensor information) which will get deprecated, when a new information is available.

I know, this is a very special problem, which didn't occur in normal or even abnormal situations. But I'm sure there are some other people having the this problem, too. So I'm glad to share my solution.

(*you remember the good ol' times with modems over telephone lines? When the internet was called BBS? And how it suddenly feels, when the BBS starts using ANSI? This was comfortable compared to our problem..)

Greetings
Ralph Erdt
