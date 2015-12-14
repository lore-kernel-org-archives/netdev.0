From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 net-next] ipv6: allow routes to be configured with
 expire values
Date: Mon, 14 Dec 2015 18:16:59 +0100
Message-ID: <566EF98B.8060704@stressinduktion.org>
References: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449678473.git.lucien.xin@gmail.com>
 <20151211.202157.2045048466167764855.davem@davemloft.net>
 <CADvbK_fxww6-EfDgdo-4e=UscsB_pvJO4z1NAPiFyujiA5xr0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58489 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752991AbbLNRRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 12:17:01 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id E5FF820F11
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:17:00 -0500 (EST)
In-Reply-To: <CADvbK_fxww6-EfDgdo-4e=UscsB_pvJO4z1NAPiFyujiA5xr0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 14.12.2015 12:48, Xin Long wrote:
>>
>> This is the wrong way to do this.
>>
>> Currently we only ever dump rta_cacheinfo values to the user.
>>
>> If we use it to set things, we have to completely consider every
>> member of that structure as potentially having meaning either
>> intended by the user or choosen by us in the future.
>>
>> Therefore it is a poor choice to start using for specifying the
>> expires value, and some other mechanism such as a new RTNETLINK
>> attribute, should be used for this.
> 
> we did it like this to avoid adding the new RTNETLINK attribute.
> now I got your meaning, and rta_cacheinfo seems to be designed
> for dumping info, not for seting info. i guess you hope we do it like:
> 
> +       if (tb[RTA_EXPIRES]) {
> +               unsigned long timeout =
> addrconf_timeout_fixup(nla_get_u32(tb[RTA_EXPIRES]), HZ);
> +
> +               if (addrconf_finite_timeout(timeout)) {
> +                       cfg->fc_expires = jiffies_to_clock_t(timeout * HZ);
> +                       cfg->fc_flags |= RTF_EXPIRES;
> +               }
> +       }
> 
> hi Hannes, we seem to go back here again, what do you think ?

Albeit I had the same idea and wanted to introduce a new netlink
attribute, I decided to recommend this patch. It aligns with the code we
already have for adding and listing ipv4 and ipv6 addresses
(ifa_cacheinfo) and reporting routing changes for ipv4 and ipv6
(rta_cacheinfo).

We can easily switch to new attributes. Should we introduce a new
interface for this?

Thanks,
Hannes
