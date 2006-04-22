From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sat, 22 Apr 2006 13:48:46 +0200
Message-ID: <20060422114846.GA6629@wohnheim.fh-wedel.de>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <20060420.120955.28255828.davem@davemloft.net> <200604211852.47335.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu,
	netdev@vger.kernel.org, Ingo Oeser <ioe-lkml@rameria.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:28112 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1751169AbWDVUl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 16:41:58 -0400
To: Ingo Oeser <netdev@axxeo.de>
Content-Disposition: inline
In-Reply-To: <200604211852.47335.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 April 2006 18:52:47 +0200, Ingo Oeser wrote:
> What about sth. like
>=20
> struct netchannel {
>    /* This is only read/written by the writer (producer) */
>    unsigned long write_ptr;
>   struct netchannel_buftrailer *netchan_queue[NET_CHANNEL_ENTRIES];
>=20
>    /* This is modified by both */
>   atomic_t filled_entries; /* cache_line_align this? */
>=20
>    /* This is only read/written by the reader (consumer) */
>    unsigned long read_ptr;
> }
>=20
> This would prevent this bug from the beginning and let us still use t=
he
> full queue size.
>=20
> If cacheline bouncing because of the shared filled_entries becomes an=
 issue,
> you are receiving or sending a lot.

Unless I completely misunderstand something, one of the main points of
the netchannels if to have *zero* fields written to by both producer
and consumer.  Receiving and sending a lot can be expected to be the
common case, so taking a performance hit in this case is hardly a good
idea.

I haven't looked at Davem's implementation at all, but Van simply
seperated fields in consumer-written and producer-written, with proper
alignment between them.  Some consumer-written fields are also read by
the producer and vice versa.  But none of this results in cacheline
pingpong.

If your description of the problem is correct, it should only mean
that the implementation has a problem, not the concept.

J=F6rn

--=20
Time? What's that? Time is only worth what you do with it.
-- Theo de Raadt
