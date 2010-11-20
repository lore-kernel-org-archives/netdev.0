From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: don't use atomic bit operation
Date: Sun, 21 Nov 2010 07:40:53 +0800
Message-ID: <AANLkTimyLOUda3NWVYhx4+2LCxRMy9JAtujL9GCEOv=5@mail.gmail.com>
References: <1289725534-8439-1-git-send-email-xiaosuo@gmail.com> <4CE1129E.5040505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CE1129E.5040505@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 15, 2010 at 6:59 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> On 14.11.2010 10:05, Changli Gao wrote:
>> As we own ct, and the others can't see it until we confirm it, we do=
n't
>> need to use atomic bit operation on ct->status.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0include/net/netfilter/nf_nat_core.h | =A0 =A04 ++--
>> =A0net/ipv4/netfilter/nf_nat_core.c =A0 =A0| =A0 =A04 ++--
>> =A02 files changed, 4 insertions(+), 4 deletions(-)
>> diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfi=
lter/nf_nat_core.h
>> index 33602ab..52ac1d8 100644
>> --- a/include/net/netfilter/nf_nat_core.h
>> +++ b/include/net/netfilter/nf_nat_core.h
>> @@ -21,9 +21,9 @@ static inline int nf_nat_initialized(struct nf_con=
n *ct,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0enum nf_nat_manip_type manip)
>> =A0{
>> =A0 =A0 =A0 if (manip =3D=3D IP_NAT_MANIP_SRC)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return test_bit(IPS_SRC_NAT_DONE_BIT, &ct-=
>status);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return IPS_SRC_NAT_DONE_BIT & ct->status;
>> =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 return test_bit(IPS_DST_NAT_DONE_BIT, &ct-=
>status);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return IPS_DST_NAT_DONE_BIT & ct->status;
>> =A0}
>
> Looks fine, but I changed the order to ct->status & ...
>

Sorry, I made a mistake. The suffix _BIT should be removed.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
