From: "Vincent, Pradeep" <pradeepv@amazon.com>
Subject: UDP Fragmentation and DF bit..
Date: Wed, 26 May 2010 18:45:47 -0700
Message-ID: <C8231CDB.16FC5%pradeepv@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:20126 "EHLO
	smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab0E0Bpv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 21:45:51 -0400
Received: from ex-hub-9001.ant.amazon.com (ex-hub-9001.sea19.amazon.com [10.185.10.26])
	by smtp-in-9003.sea19.amazon.com (8.12.11/8.12.11) with ESMTP id o4R1jnUO006267
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 01:45:49 GMT
Content-Language: en
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After running into issues with UDP in multi-MTU network environment, I
started digging through the code and found somewhat inconsistent behavi=
or
(if I read the code right)

OMan 7 ip=B9 declares that =B3The  system-wide  default  is  controlled=
  by  the
ip_no_pmtu_disc  sysctl  for SOCK_STREAM  sockets,  and  disabled  on a=
ll
others.=B2 which led me to think ODF=B9 bit will not be set for UDP pac=
kets.
But..

The code in ip_output.c seems to do the following,

1. If packet size <=3D current PMTU, then set the DF=3D1 and send the p=
acket
out.
2. If packet size > current PMTU, then set DF=3D0 and send the packet o=
ut
after fragmentation.

In a network environment where MTU-big and MTU-small co-exist (and have
router=B9s fragmentation turned off in favor of PMTU discovery), UDP pa=
ckets
that are > MTU-small and < MTU-big find the PMTU effectively but UDP pa=
ckets
that are > MTU-big get dropped. This looks like inconsistent behavior t=
o me
and doesn=B9t seem to match the advertised behavior.

Is there a reason why PMTU support for UDP is somewhat inconsistent ?

Is there a reason ODF=B9 bit cannot be set on fragmented packets on UDP
transmission ? I couldn=B9t find anything in RFC for IP protocol that
prohibited DF bit on fragmented packets. Did I miss
something here ?

Would it be reasonable if PMTU discovery is performed (DF bit set +
appropriate icmp logic) even for locally fragmented packets ? I think t=
his
will be a great help for UDP users that don=B9t have PMTU handling logi=
c in
the application (most udp applications belong to this category in my
experience). Thoughts ?

Thanks,

- Pradeep Vincent

