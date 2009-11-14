From: Ang Way Chuang <wcang79@gmail.com>
Subject: Re: TCP throughput drops sharply around MTU of 180 bytes
Date: Sat, 14 Nov 2009 17:24:56 +0800
Message-ID: <51d384e10911140124g285621a5n54afa1bdb1b02997@mail.gmail.com>
References: <51d384e10911140028r76e1aefei3a224b5c542d82e8@mail.gmail.com>
	 <4AFE6FF0.3030101@gmail.com> <4AFE748C.3050100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:43963 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754900AbZKNJYv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 04:24:51 -0500
Received: by pzk1 with SMTP id 1so1800502pzk.33
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2009 01:24:56 -0800 (PST)
In-Reply-To: <4AFE748C.3050100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I assume that ip route .... advmss achieves that effect? I tried it,
but it doesn't work.


On Sat, Nov 14, 2009 at 5:12 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Eric Dumazet a =E9crit :
>>
>> Oh well, this reminds me TCP_MAXSEG doesnt work as expected...
>
> Oops, this problem I had few years ago was fixed last year in 2.6.27,=
 sorry ...
>
> commit f5fff5dc8a7a3f395b0525c02ba92c95d42b7390
> Author: Tom Quetchenbach <virtualphtn@gmail.com>
> Date: =A0 Sun Sep 21 00:21:51 2008 -0700
>
> =A0 =A0tcp: advertise MSS requested by user
>
> =A0 =A0I'm trying to use the TCP_MAXSEG option to setsockopt() to set=
 the MSS
> =A0 =A0for both sides of a bidirectional connection.
>
> =A0 =A0man tcp says: "If this option is set before connection establi=
shment, it
> =A0 =A0also changes the MSS value announced to the other end in the i=
nitial
> =A0 =A0packet."
>
> =A0 =A0However, the kernel only uses the MTU/route cache to set the a=
dvertised
> =A0 =A0MSS. That means if I set the MSS to, say, 500 before calling c=
onnect(),
> =A0 =A0I will send at most 500-byte packets, but I will still receive=
 1500-byte
> =A0 =A0packets in reply.
>
> =A0 =A0This is a bug, either in the kernel or the documentation.
>
> =A0 =A0This patch (applies to latest net-2.6) reduces the advertised =
value to
> =A0 =A0that requested by the user as long as setsockopt() is called b=
efore
> =A0 =A0connect() or accept(). This seems like the behavior that one w=
ould
> =A0 =A0expect as well as that which is documented.
>
> =A0 =A0I've tried to make sure that things that depend on the adverti=
sed MSS
> =A0 =A0are set correctly.
>
> =A0 =A0Signed-off-by: Tom Quetchenbach <virtualphtn@gmail.com>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
>
>
