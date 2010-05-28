From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: Re: fn_trie_lookup and fn_hash_lookup
Date: Fri, 28 May 2010 11:43:31 +0530
Message-ID: <AANLkTiksJuR3vzK2SgfT3BnwddMbTq3SX3ae2PMKXd0O@mail.gmail.com>
References: <AANLkTikmIzPaOKdlXtCwosfJXzaKY1vxib_MdqI0vN_5@mail.gmail.com>
	<20100527204055.406343eb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:51797 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777Ab0E1GNc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 02:13:32 -0400
In-Reply-To: <20100527204055.406343eb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 28, 2010 at 9:10 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 28 May 2010 08:53:11 +0530
> ratheesh k <ratheesh.ksz@gmail.com> wrote:
>
>> hi ,
>>
>> I was looking into 2.6.18 kernel . I can see two functions
>> fn_trie_lookup , fn_hash_lookup
>>
>> ipv4/fib_trie.c: =A0 =A0 =A0tb->tb_lookup =3D fn_trie_lookup;
>> ipv4/fib_hash.c: =A0 =A0 =A0tb->tb_lookup =3D fn_hash_lookup;
>>
>> What is the differnce between these two functions ?
>
> They are the two possible FIB algorithms configurable.
>
> net/ipv4/Kconfig:
>
> choice
> =A0 =A0 =A0 =A0prompt "Choose IP: FIB lookup algorithm (choose FIB_HA=
SH if unsure)"
> =A0 =A0 =A0 =A0depends on IP_ADVANCED_ROUTER
> =A0 =A0 =A0 =A0default ASK_IP_FIB_HASH
>
> config ASK_IP_FIB_HASH
> =A0 =A0 =A0 =A0bool "FIB_HASH"
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0Current FIB is very proven and good enough for mos=
t users.
>
> config IP_FIB_TRIE
> =A0 =A0 =A0 =A0bool "FIB_TRIE"
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0Use new experimental LC-trie as FIB lookup algorit=
hm.
> =A0 =A0 =A0 =A0 =A0This improves lookup performance if you have a lar=
ge
> =A0 =A0 =A0 =A0 =A0number of routes.
>
> =A0 =A0 =A0 =A0 =A0LC-trie is a longest matching prefix lookup algori=
thm which
> =A0 =A0 =A0 =A0 =A0performs better than FIB_HASH for large routing ta=
bles.
> =A0 =A0 =A0 =A0 =A0But, it consumes more memory and is more complex.
>
> =A0 =A0 =A0 =A0 =A0LC-trie is described in:
>
> =A0 =A0 =A0 =A0 =A0IP-address lookup using LC-tries. Stefan Nilsson a=
nd Gunnar Karlsson
> =A0 =A0 =A0 =A0 =A0IEEE Journal on Selected Areas in Communications, =
17(6):1083-1092,
> =A0 =A0 =A0 =A0 =A0June 1999
>
> =A0 =A0 =A0 =A0 =A0An experimental study of compression methods for d=
ynamic tries
> =A0 =A0 =A0 =A0 =A0Stefan Nilsson and Matti Tikkanen. Algorithmica, 3=
3(1):19-33, 2002.
> =A0 =A0 =A0 =A0 =A0http://www.nada.kth.se/~snilsson/public/papers/dyn=
trie2/
>
>
> Also see Documentation/networking/fib_trie.txt
>
>
>

Thanks ..
