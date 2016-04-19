From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 21:08:21 +0200
Message-ID: <57168225.2040507@6wind.com>
References: <20160418.234137.26692086759328024.davem@davemloft.net>
 <1461040324.10638.159.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160419.010316.1863885429013017239.davem@davemloft.net>
 <20160419.143134.2014460805657420897.davem@davemloft.net>
 <1461091667.10638.229.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37945 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933248AbcDSTI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 15:08:26 -0400
Received: by mail-wm0-f41.google.com with SMTP id u206so45882332wme.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 12:08:25 -0700 (PDT)
In-Reply-To: <1461091667.10638.229.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/04/2016 20:47, Eric Dumazet a =C3=A9crit :
> On Tue, 2016-04-19 at 14:31 -0400, David Miller wrote:
>
>> +#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
>> +	/* IF necessary, add a zero length NOP attribute so that the
>> +	 * nla_data() of the IFLA_STATS64 will be 64-bit aligned.
>> +	 *
>> +	 * The nlattr header is 4 bytes in size, that's why we test
>> +	 * if the skb->data _is_ aligned.  This NOP attribute, plus
>> +	 * nlattr header for IFLA_STATS64, will make nla_data() 8-byte
>> +	 * aligned.
>> +	 */
>> +	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
>> +		attr =3D nla_reserve(skb, IFLA_PAD, 0);
>> +		if (!attr)
>> +			return -EMSGSIZE;
>> +	}
>> +#endif
>
> Since we want to use this in other places, we could define a helper.
>
> nla_align_64bit(skb, attribute)  or something.
Yes, with the corresponding nla_total_size_64bit()
