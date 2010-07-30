From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_nat: the checksum of ICMP doesn't have pseudo header
Date: Fri, 30 Jul 2010 18:10:19 +0800
Message-ID: <AANLkTi=YHvra6DuL7vX=DfQmR6bsw7rNMJ9mRhUzHvj2@mail.gmail.com>
References: <1280448258-1893-1-git-send-email-xiaosuo@gmail.com>
	<20100730090922.GA7807@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100730090922.GA7807@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2010 at 5:09 PM, Herbert Xu <herbert@gondor.apana.org.a=
u> wrote:
> On Fri, Jul 30, 2010 at 08:04:18AM +0800, Changli Gao wrote:
>> after updating the value of the ICMP payload, inet_proto_csum_replac=
e4() should
>> be called with zero pseudohdr.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> No, the code is correct as is. =A0We need to update the checksum
> even if the checksum is partial, which is what the 1 is for.
>

Is it really necessary, and I have noticed that netfilter doesn't call
inet_proto_csum_replace4 in this way.

static bool
icmp_manip_pkt(struct sk_buff *skb,
               unsigned int iphdroff,
               const struct nf_conntrack_tuple *tuple,
               enum nf_nat_manip_type maniptype)
{
        const struct iphdr *iph =3D (struct iphdr *)(skb->data + iphdro=
ff);
        struct icmphdr *hdr;
        unsigned int hdroff =3D iphdroff + iph->ihl*4;

        if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
                return false;

        hdr =3D (struct icmphdr *)(skb->data + hdroff);
        inet_proto_csum_replace2(&hdr->checksum, skb,
                                 hdr->un.echo.id, tuple->src.u.icmp.id,=
 0);
        hdr->un.echo.id =3D tuple->src.u.icmp.id;
        return true;
}

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
