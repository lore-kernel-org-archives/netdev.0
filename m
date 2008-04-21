From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: Re: [PATCH] soft lockup rose_node_list_lock
Date: Mon, 21 Apr 2008 22:27:27 +0200
Message-ID: <480CF8AF.9040501@ccr.jussieu.fr>
References: <480A6034.1080806@ccr.jussieu.fr>	<20080419.184010.113401925.davem@davemloft.net>	<480B78C3.4040205@ccr.jussieu.fr> <20080420.155924.86075645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-kernel@vger.kernel.org,
	linux-hams@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080420.155924.86075645.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I also spent a lot of time to understand how rose behaved and I agree=20
that it is difficult to decifer a code especially dealing
with socket programming and when it was written by someone else.
But as a radioamateur, Linux is a hobby for me and I like to learn.

Actually, rose_get_neigh() is called when two different events are=20
occuring :

- first, it is called by rose_connect() in order to find if an adjacent=
=20
node is ready to route to a specific ROSE address.
- second, rose_route_frame() calls rose_get_neigh() every time an=20
incoming frame must be routed to an appropriate AX25 connection.

By the way, rose_get_neigh() function is not optimized for it does not=20
check if an adjacent node is already connected before a new connect is=20
requested.
=46or this purpose I have derived a new function, I named=20
rose_get_route(), that is called by rose_route_frame() to find a route=20
via an adjacent node.
This function has been tested for months now and it works fine.
It adds the automatic frames routing that rose needed desperately.
I will send next a patch with this new rose_get_route().

Bernard Pidoux

p.s. my email client is set for MIME attachements, but it seems corrupt=
ed.
    I will fix that. Sorry for the unvoluntary increase of workload it=20
gave you.


David Miller a =E9crit :
> From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
> Date: Sun, 20 Apr 2008 19:09:23 +0200
>
>  =20
>> Since rose_route_frame() does not use rose_node_list we can safely
>> remove rose_node_list_lock spin lock here and let it be free for
>> rose_get_neigh().
>>
>> Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
>>    =20
>
> Indeed, I went over this code several times and I can't
> see any reason for rose_route_frame() to take the node
> list lock.
>
> Patch applied, thanks Bernard.  But one thing...
>
>  =20
>> diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
>> index fb9359f..5053a53 100644
>> --- a/net/rose/rose_route.c
>> +++ b/net/rose/rose_route.c
>> @@ -857,7 +857,6 @@ int rose_route_frame(struct sk_buff *skb, ax25_c=
b *ax25)
>>          src_addr  =3D (rose_address *)(skb->data + 9);
>>          dest_addr =3D (rose_address *)(skb->data + 4);
>>
>> -       spin_lock_bh(&rose_node_list_lock);
>>          spin_lock_bh(&rose_neigh_list_lock);
>>          spin_lock_bh(&rose_route_list_lock);
>>
>>    =20
>
> Could you please fix your email client so it doesn't corrupt
> patches like this?  I've had to apply all of your patches by
> hand because the tabs have been converted into spaces.  Use
> MIME attachments if you have to.
>
> Thanks again.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-hams"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  =20

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
