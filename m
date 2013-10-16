From: Kefeng Wang <wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/18] net: use wrapper functions of net_ratelimit() to
 simplify code
Date: Wed, 16 Oct 2013 11:24:22 +0800
Message-ID: <525E06E6.2080502@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>  <1381837514-50660-3-git-send-email-wangkefeng.wang@huawei.com> <1381854263.22110.19.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Francois Romieu" <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Chas Williams <chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Boris Ostrovsky <boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <netfilter@vger.k
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1381854263.22110.19.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks for your reply.

On 10/16 0:24, Joe Perches wrote:
> On Tue, 2013-10-15 at 19:44 +0800, Kefeng Wang wrote:
>> Wrapper functions net_ratelimited_function() and net_XXX_ratelimited()
>> are called to simplify code.
> []
>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> []
>> @@ -465,10 +465,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>>  	if (likely(fdb)) {
>>  		/* attempt to update an entry for a local interface */
>>  		if (unlikely(fdb->is_local)) {
>> -			if (net_ratelimit())
>> -				br_warn(br, "received packet on %s with "
>> -					"own address as source address\n",
>> -					source->dev->name);
>> +			net_ratelimited_function(br_warn, br, "received packet on %s "
>> +				"with own address as source address\n", source->dev->name);
> 
> Hello Kefeng.
> 
> When these types of lines are changed, please coalesce the
> fragmented format pieces into a single string.
> 
> It makes grep a bit easier and 80 columns limits don't
> apply to formats.

Got it, I will coalesce them, but 80 columns limits will be
broken.

> I think using net_ratelimited_function is not particularly
> clarifying here.
> 
> Maybe net_ratelimited_function should be removed instead
> of its use sites expanded.
> 
> Perhaps adding macros like #define br_warn_ratelimited()
> would be better.

yes, I found dev_emerg_ratelimited already exists. I should
use them and will add some similar mcaros.

> This comment applies to the whole series.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> .
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
