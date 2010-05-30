From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] act_nat: fix the wrong checksum when addr isn't in
	old_addr/mask
Date: Sun, 30 May 2010 22:11:29 +0800
Message-ID: <AANLkTilr0YX2xQW80BZmRVyAk2jv-PlkXmJkaLGj3-7v@mail.gmail.com>
References: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com>
	<1275223421.3587.0.camel@bigi> <20100530125811.GA8120@gondor.apana.org.au>
	<AANLkTinDe-AluGZx87q3nvxCfushfeH0jS35Fav95IXk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51884 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966Ab0E3OLu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 10:11:50 -0400
Received: by pvg11 with SMTP id 11so1014721pvg.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 07:11:49 -0700 (PDT)
In-Reply-To: <AANLkTinDe-AluGZx87q3nvxCfushfeH0jS35Fav95IXk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 30, 2010 at 9:33 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> On Sun, May 30, 2010 at 8:58 PM, Herbert Xu <herbert@gondor.apana.org=
=2Eau> wrote:
>>
>> Yes the patch is correct.
>>
>> However, the fact that you need this patch means that your act_nat
>> setup isn't perfect. =C2=A0Ideally all the unNATed packets should be
>> filtered out before you hit act_nat.
>
> Thinking about this topologic:
>
> client -> DNAT -> router -> server.
>
> DNAT is used to map a public IP to server's private IP. If a
> DEST_UNREACH ICMP packet is sent out by router, in order to handle
> this ICMP packet correctly, I have to pass it to act_nat.c. How can I
> filter out the other packets? By inspecting the inner IP destination
> address of this ICMP packet? Maybe I can use u32 with complicate
> parameters.
>

Oh, I can pass all the ICMP packets, and the packets to the public IP
and the packets from the private IP.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
