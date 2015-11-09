From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH RFC 2/6] net/ncsi: Packet handler
Date: Mon, 09 Nov 2015 11:41:24 +1100
Message-ID: <1447029684.8727.38.camel@kernel.crashing.org>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1447027806-4744-3-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37110 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbbKIAld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 19:41:33 -0500
In-Reply-To: <1447027806-4744-3-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-09 at 11:10 +1100, Gavin Shan wrote:
> +
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Send NCSI packet */
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0skb_get(nr->nr_cmd);
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ret =3D dev_queue_xmit_sk(=
NULL, nr->nr_cmd);
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (ret)
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0goto out;
> +

Probably just dev_queue_xmit() in recent kernels

This means the queue needs to be running, which means the carrier needs
to be "on".

Dave, this is a problem actually. The NC-SI connection can be to
several NICs that may or may not have a link up. The "stack" will chose
one based on policies that we can discuss separately but basically, I
think we should reflect whether we found a NIC and it has a link up in
the "carrier" setting of our driver.

The problem with doing that is that if the carrier is "off", then
there's some code nowadays that will put a noop qdisc in and we won't
be able to send the low level NC-SI packets to communicate with the NIC
and thus find a new one or get a new carrier indication.

So at the moment, we must have the carrier of the driver appear as
"always on" when using NC-SI.

Cheers,
Ben.
