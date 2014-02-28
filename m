From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: send arp requests even if there's no
 route to them
Date: Fri, 28 Feb 2014 12:40:57 +0100
Message-ID: <20140228114056.GB11907@redhat.com>
References: <1393585076-22786-1-git-send-email-vfalico@redhat.com>
 <1393585971.10280.5.camel@joe-AO722>
 <20140228112840.GA11907@redhat.com>
 <1393587499.10280.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org,
	=?iso-8859-1?Q?Fran=E7ois?= CACHEREUL <f.cachereul@alphalink.fr>,
	Zhenjie Chen <zhchen@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbaB1LlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 06:41:09 -0500
Content-Disposition: inline
In-Reply-To: <1393587499.10280.10.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 28, 2014 at 03:38:19AM -0800, Joe Perches wrote:
>On Fri, 2014-02-28 at 12:28 +0100, Veaceslav Falico wrote:
>> On Fri, Feb 28, 2014 at 03:12:51AM -0800, Joe Perches wrote:
>> >On Fri, 2014-02-28 at 11:57 +0100, Veaceslav Falico wrote:
>> ...snip...
>> >> +			if (bond->params.arp_validate)
>> >> +				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
>> >> +					bond->dev->name, &targets[i]);
>> >
>> >Maybe
>> >
>> >			if (bond->params.arp_validate && net_ratelimit())
>>
>> Hm, not that I'm against it - but bond_arp_send_all() is called every
>> arp_interval - which is usually >50ms. Does it really make sense to put it
>> here?
>
>Dunno, but you're converting a generally not emitted pr_debug
>(DEBUG isn't set, so it'd have to be enabled by dynamic_debug)
>to something that'll always print out a line for each of up to
>16 targets, so it seems it could be pretty noisy.

Yeah, completely agree (I've missed that there might be 16 targets).

Thanks a lot, will resend.

>
>
