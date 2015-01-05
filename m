From: Hubert Sokolowski <hubert.sokolowski@intel.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Mon, 05 Jan 2015 12:56:16 +0000
Message-ID: <54AA89F0.9090009@intel.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com>    <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl>    <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com>    <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com>    <5491A3B5.9070601@redhat.com> <e3ac4e3535a18f6dd1cf31030674f91c.squirrel@poczta.wsisiz.edu.pl> <54935618.4070005@mojatatu.com> <5494418B.1000004@intel.com> <5494532D.4040203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, vyasevic@redhat.com,
	John Fastabend <john.fastabend@gmail.com>,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:29956 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175AbbAEM6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 07:58:19 -0500
In-Reply-To: <5494532D.4040203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19/12/14 16:32, Roopa Prabhu wrote:
> On 12/19/14, 7:17 AM, Hubert Sokolowski wrote:
>> On 18/12/14 22:32, Jamal Hadi Salim wrote:
>>
>>> Sorry for the latency (head-buried-in-sand in effect)
>>> On 12/17/14 11:18, Hubert Sokolowski wrote:
>>>> I have just prepared a patch where I dump uc/mc for bridge devices
>>>> by looking at (dev->priv_flags & IFF_EBRIDGE), so I have same results
>>>> as without my changes. This should satisfy Jamal and Roopa.
>>>> I could send it as v3 of my patch along with the results if you are
>>>> interested.
>>> Please do. If you satisfy Vlad's goals then we are all happy.
>> Posted as v3, please review.
>> There is still open question I asked sometime ago but never got explained.
>> It is about the new filter_dev parameter that was added to ndo_fdb_dump:
>>          int                     (*ndo_fdb_dump)(struct sk_buff *skb,
>>                                                  struct netlink_callback *cb,
>>                                                  struct net_device *dev,
>>                                                  struct net_device *filter_dev,
>>                                                  int idx);
>>
>> When we call this function for a device, dev pointer is passed as the filter_dev:
>>                  if (dev->netdev_ops->ndo_fdb_dump)
>>                          idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
>>                                                              idx);
> seems like these calls should be fixed. bdev is really dev in this case. And filter_dev should be null.
>

Will fix this too and resend the patch as v4.

Thanks,
Hubert

-- 
Hubert Sokolowski                  Intel Corporation
