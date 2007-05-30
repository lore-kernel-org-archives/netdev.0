From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 20:39:09 +0200
Message-ID: <465DC4CD.9080801@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p07-fb.rzone.de ([81.169.146.215]:11880 "EHLO
	cg-p07-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbXE3Smj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 14:42:39 -0400
In-Reply-To: <465DB0B6.109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> I have a set of patches coming up that introduce a rtnetlink API
> for adding/modifying/deleting software network devices. I would
> prefer if you could switch this driver over instead of doing the
> "create N devices during loading" that many current drivers do,
> leaving you with 20 unused devices after boot.
>   

Hi Patrick,

next Friday? Too late ;-)

Ok, your approach is indeed an interesting idea and we would look on it,
as we also not interested in creating unused devices and do any double
work.

> And it allows you have both loopback and non-loopback devices
> in case that would be useful.
>
> (..)
> Qdiscs might change skb->cb. Maybe use skb->sk?
>
>
>   

The loopback functionality in CAN is a bit tricky (maybe you can take a
look into the Documentation patch [7/7] at chapter 3.2 and 4.1.4).

The problem is, that we need a per socket(!) option that enables the
loopback for the sent CAN-Frames or not, so the information about
loopback a skb content or not is contained inside the skb sent down to
the CAN netdevice. If the CAN networkdevice is not capable to perform a
loopback itself (see dev->flags, chapter 6) the CAN core has to do the
loopback as a fallback.

The use of skb->cb is also needed in the receive path to recognize and
trash loopback'ed CAN-frames inside the *originating* socket (see
chapter 4.1.4).

Please consider the referenced documentation and give me a feedback, if
you have a better idea how to deal with variable loopbacks on driver
level (with is vital for CAN).

Thanks for your feedback,
Oliver


