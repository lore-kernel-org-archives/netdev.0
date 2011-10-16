From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] net: ipv6: inet6_connection_sock.h needs flowi
Date: Sun, 16 Oct 2011 12:13:39 +0300
Message-ID: <4E9AA043.1090008@uclouvain.be>
References: <1318671264-19684-1-git-send-email-christoph.paasch@uclouvain.be> <20111015.184126.53610934026688054.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:60556 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab1JPJNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 05:13:45 -0400
In-Reply-To: <20111015.184126.53610934026688054.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2011 01:41 AM, David Miller wrote:
> From: Christoph Paasch<christoph.paasch@uclouvain.be>
> Date: Sat, 15 Oct 2011 12:34:24 +0300
>
>> Otherwise we have a compiler-warning in c-files not including net/fl=
ow.h
>> before inet6_connection_sock.h .
>>
>> Signed-off-by: Christoph Paasch<christoph.paasch@uclouvain.be>
>
> Example?  I've never seen this warning.

Currently, all the c-files that include inet6_connection_sock.h=20
indirectly include flow.h before inet6_connection_sock.h. Thus currentl=
y=20
there is no compiler-warning.

However, if a c-file would include inet6_connection_sock.h without=20
preceding an inclusion of flow.h, a compiler-warning will trigger (at=20
least with gcc 4.6.1 from the latest ubuntu). Thus, the c-file has to=20
include flow.h even if it doesn't need any struct/function from flow.h.=
=20
Actually I had this case in our mptcp-code. Thus I had two choices,=20
either include flow.h in the c-file (even if it's not needed there), or=
=20
change inet6_connection_sock.h

I would say, that inet6_connection_sock.h should not rely on the c-file=
s=20
to include flow.h, and rather declare struct flowi (as it is done for=20
the other structs used in inet6_connection_sock.h like in6_addr,=20
sk_buff,...).

Or am I missing something?

Cheers,
Christoph

--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=C3=A9 Catholique de Louvain
--=20
