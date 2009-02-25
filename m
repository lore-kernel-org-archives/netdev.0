From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Wed, 25 Feb 2009 10:43:27 -0800
Message-ID: <c0a09e5c0902251043x576e7066kb7aa76fc148a6f76@mail.gmail.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	 <20090224.232814.227017310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:9550 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbZBYSn2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 13:43:28 -0500
Received: by wf-out-1314.google.com with SMTP id 28so159374wfa.4
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 10:43:27 -0800 (PST)
In-Reply-To: <20090224.232814.227017310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 11:28 PM, David Miller <davem@davemloft.net> wr=
ote:
> This makes RDMA too much of a first-class citizen in the networking
> stack. =A0That's a blocker for me.

RDS is not an RDMA protocol, it is a protocol that supports RDMA. RDS
is not an IB protocol, it is a protocol that supports IB transport.

RDS's reliable-datagram socket implementation has a modular interface
to the transport (e.g. tcp, udp, or ib) and works fine over transports
that do not support RDMA. (Most users also do not use RDMA.)

OK so we have:

1) RDS socket code
  must go in net/rds, it's socket code
2) RDS core rdma support
  move to drivers/infiniband?
3) RDS IB/iwarp transport
  keep the non-RDMA support in net/rds or move to d/i? It's not RDMA it=
's IB
4) IB/iwarp transport's rdma support
  move to d/i
5) RDS TCP transport (impl. but not incl. in patchset)
  net/rds
6) RDS UDP/DCB transport (not impl. yet)
  net/rds

Does this look right? Right now it sounds like you're saying 1, 5, and
6 go in net/rds, 2-4 go in drivers/infiniband.

I'd personally prefer to not split it up, or to split it on the
natural core/transport boundary, but I can make it work whatever you
decide. :-)

> Furthermore the port you've choosen for the protocol is arbitrary, no=
t
> properly allocated with the appropriate standards committee, and
> therefore could conflict with something other people are using.

I'm sure allocating the port won't be too big an issue.

Regards -- Andy
