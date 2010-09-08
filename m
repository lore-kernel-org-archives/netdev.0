From: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Wed, 08 Sep 2010 07:57:31 +0300
Message-ID: <4C8717BB.2050504@fs.uni-ruse.bg>
References: <20100904203429.GA4891@del.dom.local> <1283672983.3402.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1283672983.3402.38.camel@edumazet-laptop>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=D0=9D=D0=B0 05.9.2010 =D0=B3. 10:49, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> Le samedi 04 septembre 2010 =C3=A0 22:34 +0200, Jarek Poplawski a =C3=
=A9crit :
>
>> Hi again,
>>
>> Just had a second look, and unless I miss something...
>>
>> Plamen, could you test this patch, too? (Without removing the previo=
us
>> one.)
>>
>> Thanks,
>> Jarek P.
>>
>> ------------------->
>>
>> [PATCH] gro: Re-fix different skb headrooms
>>
>> The patch: "gro: fix different skb headrooms" in its part:
>> "2) allocate a minimal skb for head of frag_list" is buggy. The copi=
ed
>> skb has p->data set at the ip header at the moment, and skb_gro_offs=
et
>> is the length of ip + tcp headers. So, after the change the length o=
f
>> mac header is skipped. Later skb_set_mac_header() sets it into the
>> NET_SKB_PAD area (if it's long enough) and ip header is misaligned a=
t
>> NET_SKB_PAD + NET_IP_ALIGN offset. There is no reason to assume the
>> original skb was wrongly allocated, so let's copy it as it was.
>>
>> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=3D16626
>> fixes commit: 3d3be4333fdf6faa080947b331a6a19bce1a4f57
>>
>> Reported-by: Plamen Petrov<pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
>> Signed-off-by: Jarek Poplawski<jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> CC: Eric Dumazet<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 26396ff..c83b421 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -2706,7 +2706,7 @@ int skb_gro_receive(struct sk_buff **head, str=
uct sk_buff *skb)
>>   	} else if (skb_gro_len(p) !=3D pinfo->gso_size)
>>   		return -E2BIG;
>>
>> -	headroom =3D NET_SKB_PAD + NET_IP_ALIGN;
>> +	headroom =3D skb_headroom(p);
>>   	nskb =3D alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
>>   	if (unlikely(!nskb))
>>   		return -ENOMEM;
>
> You are right, thanks for reviewing this patch again :)
>
> By the way, NET_IP_ALIGN is now 0 on x86, so technically speaking, yo=
ur
> patch un-aligns IP header on x86, but thats OK, since other arches mi=
ght
> want it being aligned, while x86 doesnt care.
>
> Acked-by: Eric Dumazet<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
>
>

Well, now that I'm back at work, I'm glad to report
that I tested both variants of the patch, and as Eric
points out - it works both ways.

So, which ever fits you guys better.

Thanks a lot!
