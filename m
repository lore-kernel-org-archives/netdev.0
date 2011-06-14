From: Joris van Rantwijk <joris@jorisvr.nl>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Tue, 14 Jun 2011 21:37:18 +0200
Message-ID: <20110614213718.67022768@konijn>
References: <20110611215919.5fc29c27@konijn>
	<1307850224.22348.626.camel@localhost>
	<20110612095131.6d924082@konijn>
	<1307869632.2872.106.camel@edumazet-laptop>
	<20110612113004.79f48f40@konijn>
	<1307875698.2872.130.camel@edumazet-laptop>
	<20110612132428.3e1a4593@konijn>
	<1307890657.2872.158.camel@edumazet-laptop>
	<20110612213726.4d203a6e@konijn>
	<alpine.DEB.2.00.1106141302110.17529@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr4.xs4all.nl ([194.109.24.24]:2060 "EHLO
	smtp-vbr4.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab1FNTh0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 15:37:26 -0400
In-Reply-To: <alpine.DEB.2.00.1106141302110.17529@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-06-14, "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> BTW, it wouldn't be impossible to create all those "missing" ACKs on
> the TCP layer relatively cheaply when receiving the GRO'ed super
> segment.  I'm certainly not opposed you coming up such patch which
> does all that minimal work needed on TCP layer but I think it
> requires also some TSO/GSO related problem solving because TSO/GSO as
> is won't let you create such super ACKs we'd want to send out on that
> single go.

Your super-ACK idea is similar to the solution presented in this paper:
http://www.usenix.org/event/usenix08/tech/full_papers/menon/menon_html/

Actually, I started looking at the GRO code after reading that
paper, hoping to find that Linux has a better way to deal with ACKs.

The super ACK doesn't look easy. It must contain all different ack_seq
values to avoid tripping duplicate ACK detection. Ideally, the ack_seq
values would match real seq values from the received segments.

I don't currently have a setup where I could test these kinds of
changes, so this doesn't seem like a job for me. At least not right now=
=2E

Thanks, Joris.
