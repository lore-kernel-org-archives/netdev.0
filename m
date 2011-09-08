From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 3/3 RFC] macvtap: Add support for
 TUNSETTXFILTER
Date: Thu, 08 Sep 2011 12:06:05 -0700
Message-ID: <CA8E602D.33B8C%roprabhu@cisco.com>
References: <201109081825.31065.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dragos.tatulea@gmail.com>,
	<mst@redhat.com>, <dwang2@cisco.com>, <benve@cisco.com>,
	<kaber@trash.net>, <sri@us.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:59945 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab1IHXbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 19:31:46 -0400
In-Reply-To: <201109081825.31065.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/8/11 9:25 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Wednesday 07 September 2011, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roprabhu@cisco.com>
>> 
>> This patch adds support for TUNSETTXFILTER. Calls macvlan set filter function
>> with address list and flags received via TUNSETTXFILTER.
>> 
>> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
>> Signed-off-by: Christian Benvenuti <benve@cisco.com>
>> Signed-off-by: David Wang <dwang2@cisco.com>
> 
> Looks ok to me in principle, but
> 
>> +               /* XXX: If broadcast address present, set IFF_BROADCAST */
>> +               /* XXX: If multicast address present, set IFF_MULTICAST */
>> +               flags |= (tf.flags & TUN_FLT_ALLMULTI ? IFF_ALLMULTI : 0) |
>> +                        (!tf.count ? IFF_PROMISC : 0);
>> +               ret = 0;
>> +               if (tf.count > 0) {
>> +                       alen = ETH_ALEN * tf.count;
>> +                       addrs = kmalloc(alen, GFP_KERNEL);
>> +                       if (!addrs) {
>> +                               dev_put(vlan->dev);
>> +                               return -ENOMEM;
>> +                       }
> 
> I think you need to check tf.count for a maximum value. In theory, a user
> could pass a rather large number (65536) which is not good.

Good point. Will fix it.

> 
> Also the TUNSETTXFILTER code looks sufficiently large that it would be
> better to put it into a separate function. Use "goto" statements in
> order to do the error handling in there, instead of repeating
> lots of kfree and dev_put calls in each error case.

Ok sounds good. Will fix this when I respin the patches.

Thanks for the comments.
Roopa
