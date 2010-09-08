From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Wed, 8 Sep 2010 06:20:04 +0000
Message-ID: <20100908062004.GA6280@ff.dom.local>
References: <20100904203429.GA4891@del.dom.local> <1283672983.3402.38.camel@edumazet-laptop> <4C8717BB.2050504@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42999 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab0IHGUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 02:20:13 -0400
Content-Disposition: inline
In-Reply-To: <4C8717BB.2050504@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 08, 2010 at 07:57:31AM +0300, Plamen Petrov wrote:
> ???? 05.9.2010 ??. 10:49, Eric Dumazet ????????????:
>> Le samedi 04 septembre 2010 ?? 22:34 +0200, Jarek Poplawski a =E9cri=
t :
>>
>>> Hi again,
>>>
>>> Just had a second look, and unless I miss something...
>>>
>>> Plamen, could you test this patch, too? (Without removing the previ=
ous
>>> one.)
>>>
>>> Thanks,
>>> Jarek P.
>>>
>>> ------------------->
>>>
>>> [PATCH] gro: Re-fix different skb headrooms
>>>
>>> The patch: "gro: fix different skb headrooms" in its part:
>>> "2) allocate a minimal skb for head of frag_list" is buggy. The cop=
ied
>>> skb has p->data set at the ip header at the moment, and skb_gro_off=
set
>>> is the length of ip + tcp headers. So, after the change the length =
of
>>> mac header is skipped. Later skb_set_mac_header() sets it into the
>>> NET_SKB_PAD area (if it's long enough) and ip header is misaligned =
at
>>> NET_SKB_PAD + NET_IP_ALIGN offset. There is no reason to assume the
>>> original skb was wrongly allocated, so let's copy it as it was.
>>>
>>> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=3D16626
>>> fixes commit: 3d3be4333fdf6faa080947b331a6a19bce1a4f57
>>>
>>> Reported-by: Plamen Petrov<pvp-lsts@fs.uni-ruse.bg>
>>> Signed-off-by: Jarek Poplawski<jarkao2@gmail.com>
>>> CC: Eric Dumazet<eric.dumazet@gmail.com>
>>> ---
>>>
>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>> index 26396ff..c83b421 100644
>>> --- a/net/core/skbuff.c
>>> +++ b/net/core/skbuff.c
>>> @@ -2706,7 +2706,7 @@ int skb_gro_receive(struct sk_buff **head, st=
ruct sk_buff *skb)
>>>   	} else if (skb_gro_len(p) !=3D pinfo->gso_size)
>>>   		return -E2BIG;
>>>
>>> -	headroom =3D NET_SKB_PAD + NET_IP_ALIGN;
>>> +	headroom =3D skb_headroom(p);
>>>   	nskb =3D alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
>>>   	if (unlikely(!nskb))
>>>   		return -ENOMEM;
>>
>> You are right, thanks for reviewing this patch again :)
>>
>> By the way, NET_IP_ALIGN is now 0 on x86, so technically speaking, y=
our
>> patch un-aligns IP header on x86, but thats OK, since other arches m=
ight
>> want it being aligned, while x86 doesnt care.
>>
>> Acked-by: Eric Dumazet<eric.dumazet@gmail.com>
>>
>>
>>
>
> Well, now that I'm back at work, I'm glad to report
> that I tested both variants of the patch, and as Eric
> points out - it works both ways.
>
> So, which ever fits you guys better.

We need both of them. I hope David could add this too:

Tested-by: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>

Thanks a lot everybody!
Jarek P.
