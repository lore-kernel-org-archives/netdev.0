From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: unused code in net/netfilter/ipset/ip_set_bitmap_ipmac.c
Date: Mon, 29 Feb 2016 12:23:27 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1602291218360.21350@blackhole.kfki.hu>
References: <alpine.DEB.2.10.1602291202590.2600@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1602291202590.2600@hadrien>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 29 Feb 2016, Julia Lawall wrote:

> The file net/netfilter/ipset/ip_set_bitmap_ipmac.c seems to contain a lot
> of static functions that are not used in the file:
> 
> bitmap_ipmac_add_timeout
> bitmap_ipmac_do_add
> bitmap_ipmac_do_del
> bitmap_ipmac_do_head
> bitmap_ipmac_do_list
> bitmap_ipmac_do_test
> bitmap_ipmac_gc_test
> bitmap_ipmac_is_filled
> bitmap_ipmac_kadt
> bitmap_ipmac_same_set
> bitmap_ipmac_uadt
> 
> Have I overooked something?

Yes: the file includes ip_set_bitmap_gen.h in which all those functions 
are used.
 
> I was looking at this code, with Daniel Borkmann, because there seems to
> be a bug in the function bitmap_ipmac_uadt:
> 
> 	if (tb[IPSET_ATTR_ETHER]) {
>                 memcpy(e.ether, nla_data(tb[IPSET_ATTR_ETHER]), ETH_ALEN);
>                 e.add_mac = 1;
>         }
> 
> Later in the same file, there is:
> 
> static struct ip_set_type bitmap_ipmac_type = {
> 	...
>         .adt_policy     = {
> 		...
> 		[IPSET_ATTR_ETHER]      = { .type = NLA_BINARY,
>                                             .len  = ETH_ALEN },
> 		...},
> 	...
> };
> 
> The type NLA_BINARY indicates that the length is a maximum possible
> length, and thus a check of the actual length is needed before the memcpy.

You are right here (and the similar spotting in ip_set_hash_mac.c) - I'll 
prepare a patch and submit it.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
