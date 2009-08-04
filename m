From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 04 Aug 2009 08:16:06 -0700
Message-ID: <87ws5jlidl.fsf@caffeine.danplanet.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-6-git-send-email-danms@us.ibm.com>
	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
	<4A6F6B19.9010508@librato.com> <878wi6yxui.fsf@caffeine.danplanet.com>
	<4A77F0EF.9090602@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Oren Laadan <orenl@librato.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:39002 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932624AbZHDPQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 11:16:08 -0400
In-Reply-To: <4A77F0EF.9090602@librato.com> (Oren Laadan's message of "Tue\, 04 Aug 2009 04\:27\:27 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OL> Does this mean that a situation of A->B and B->C is valid only as
OL> long as A->B is done first, otherwise A->B will fail because B
OL> will already be connected to C ?

Correct.

OL> Then, the other problem is to restore correctly you need to mimic
OL> the behavior of sendto() because of the way the skb references the
OL> original socket for the write-buf accounting :(

OL> In turn, this means that during checkpoint you need to record the
OL> _origin_ of each buffer in the queue of afunix dgram sockets :((

Or return EBUSY when there are skb's that are outstanding from before
the re-connect, right?

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
