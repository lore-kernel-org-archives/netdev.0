From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: IPv6 raw socket and recvfrom
Date: Tue, 17 Aug 2010 15:08:51 +0200
Message-ID: <41bd6ed1194a332231874b2975efe97a@chewa.net>
References: <20100817143120.7fad5186@tux.DEF.witbe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Paul Rolland <rol@as2917.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:48395 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891Ab0HQNIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 09:08:53 -0400
In-Reply-To: <20100817143120.7fad5186@tux.DEF.witbe.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 17 Aug 2010 14:31:20 +0200, Paul Rolland <rol@as2917.net> wrote=
:=0D
> I'd like someone to clarify the behavior I can expect from a RAW IPv6=
=0D
> socket _in Linux_ :=0D
>  - Raw IPv4 sockets : recvfrom() payload contain all the IP header,=0D
>    including src ip, dst ip, etc...=0D
> =0D
>  - Raw IPv6 sockets : so far, recvfrom returns me only the payload. I=
've=0D
>    added the HDRINCL options, but it seems that this is a no-op in=0D
>    IPv6-land.=0D
=0D
Yes and no. You get the packet size from the return value of recvfrom()=
=2E=0D
You can also get the source address from the recvfrom() address paramet=
er.=0D
And you can additionally get the hop limit, destination address and typ=
e of=0D
service as ancillary data with recvmsg(). Finally, you can have the ker=
nel=0D
verify the checksum field for you (and discard broken packets), and of=0D
course the IP version. In the end, the only unknown field is the flow=0D
information, for which there is no standardized API that I know.=0D
=0D
> I've reviewed RFC 3542, which states that I'm not to expect ip6 heade=
r,=0D
> but often "there is more than one way to do it", and I'd like to be s=
ure=0D
> I'm not missing something obvious=0D
=0D
On Linux, you should use AF_PACKET sockets if you want to receive (or s=
end)=0D
raw packets including the network header. Alternatively, you can use=0D
libpcap (which really is a wrapper around AF_PACKET anyway).=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

