From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] vlan: allow VLAN ID 0 to be used
Date: Tue, 27 Oct 2009 10:52:41 +0100
Message-ID: <m3aazdb1ue.fsf@ursa.amorsen.dk>
References: <477963.52849.qm@web32605.mail.mud.yahoo.com>
	<m34opmr2fz.fsf@ursa.amorsen.dk> <4AE563C7.5070702@gmail.com>
	<4AE5CAC6.4000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: unlisted-recipients:; (no To-header on input)
	Gertjan Hofman <gertjan_hofman@yahoo.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:36090 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752352AbZJ0Jwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 05:52:43 -0400
In-Reply-To: <4AE5CAC6.4000604@gmail.com> (Eric Dumazet's message of "Mon, 26
	Oct 2009 17:13:58 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Here is the patch I cooked that permitted VLAN 0 to be used with tg3
> (and other HW accelerated vlan nics I suppose)
>
> [PATCH] vlan: allow VLAN ID 0 to be used
>
> We currently use a 16 bit field (vlan_tci) to store VLAN ID on a skb.
>
> 0 value is used a special value, meaning VLAN ID not set.
> This forbids use of VLAN ID 0

Are you sure you actually want to do this?

VLAN 0 IS special. Frames received on VLAN 0 should be treated just as
if they had no VLAN tag at all, except that they have an 802.1p value.

Sending frames with VLAN 0 should have something to do with whether
the sender wants to use 802.1p, which doesn't really have much to do
with VLAN's at all...

It would be nice if the unsuspecting user was at least warned that their
use of VLAN 0 is non-standard and may cause surprising results like
leakage into the "native" VLAN. That could be done in /sbin/ip or
/sbin/vconfig, of course.


/Benny

