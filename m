From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [PATCH net-next v3] net: add skb allocation flags to pskb_copy
Date: Wed, 11 Jun 2014 12:59:26 +0300
Message-ID: <CAE1zotKXQwk89QLmc-PWMO69qgUgTVmbQTbc2EzbTXCF61tyXw@mail.gmail.com>
References: <1402477954-1267-1-git-send-email-octavian.purdila@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1725AC13@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Arvid Brodin <arvid.brodin@alten.se>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hend
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:58953 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbaFKJ72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 05:59:28 -0400
Received: by mail-we0-f173.google.com with SMTP id t60so1976917wes.4
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 02:59:27 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725AC13@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 12:22 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Octavian Purdila
>> There are several instances where a pskb_copy or __pskb_copy is
>> immediately followed by an skb_clone. Add a new parameter to allow the
>> skb to be allocated from the fclone cache and thus speed up subsequent
>> skb_clone calls.
> ...
>> @@ -2233,9 +2233,9 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
>>  }
>>
>>  static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
>> -                                     gfp_t gfp_mask)
>> +                                     gfp_t gfp_mask, bool fclone)
>>  {
>> -     return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
>> +     return __pskb_copy(skb, skb_headroom(skb), gfp_mask, fclone);
> ...
>
> Why not add:
> static inline struct sk_buff *pskb_copy_for_clone(struct sk_buff *skb,
>                                         gfp_t gfp_mask)
> {
>         return __pskb_copy(skb, skb_headroom(skb), gfp_mask, true);
> }
>
> So that only some of the call sites need changing.
> The different function name is probably easier to grok than a Boolean
> parameter.
>

Hi David,

Since cloning a copy seems to be more frequent then one would thought,
I think that explicitly adding the option will force people to think
about allocating from the fclone cache.

But I don't care much either way, so if people think a new function is
better I will rework the patch.

Thanks,
Tavi
