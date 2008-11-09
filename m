From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: fix /proc/net/snmp as memory corruptor
Date: Sun, 09 Nov 2008 09:25:54 +0100
Message-ID: <49169E92.8080802@cosmosbay.com>
References: <OF3DE3524D.66B1A705-ON882574FB.00729B02-882574FB.0073D449@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>, alan@lxorguk.ukuu.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Eric Sesterhenn <snakebyte@gmx.de>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34824 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbYKII0Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 03:26:24 -0500
In-Reply-To: <OF3DE3524D.66B1A705-ON882574FB.00729B02-882574FB.0073D449@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens a =E9crit :
>> If you are not sure what I am talking about, then you should probabl=
y
>> not use static variables at all. I found this fix quite obvious...
>=20
>         Actually, I didn't realize "out" was static -- was looking at=
 just
> the patch, and obviously missing your point.
>         I don't have a problem with 16 ints on the stack (or shorts, =
as
> you pointed out)-- I didn't want the data on the stack, which may be
> 64-bit ints. In your patch, you're collecting all of it on the stack
> (doubling its size).
>         If there is no interlocking at a higher layer (and I haven't=20
> looked
> at this in a long time...) (ie, exclusive opens), then I agree, it
> shouldn't be static.
>=20
>         Why not just that? (ie, add count=3D0 as Alexey did and remov=
e the
> static qualifier from "out")

Well, this patch also saves 143+64 bytes because of the cleanup.

before :
# size net/ipv4/proc.o
   text    data     bss     dec     hex filename
   5191      16      64    5271    1497 net/ipv4/proc.o

After :
# size net/ipv4/proc.o
   text    data     bss     dec     hex filename
   5048      16       0    5064    13c8 net/ipv4/proc.o

1) bug correction from Alexey
2) bug correction about using a static array without exclusion
3) minor cleanup to save 143 bytes of text and 64 bytes of data
4) save thousand of cpu cycles if many possible cpus.
5) Actually works, even if using 128 bytes on stack, in a function
   that only calls seq_printf() (we are not in the network stack)



