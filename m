From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [RFC 11/12] 6lowpan: add support for getting short address
Date: Fri, 27 May 2016 15:20:15 +0200
Message-ID: <5748498F.8040309@osg.samsung.com>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
 <1464031328-17524-12-git-send-email-aar@pengutronix.de>
 <57481BEB.6050105@osg.samsung.com>
 <b25a477f-0bb1-979e-1bfe-a8b35dc0d289@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:55036 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754212AbcE0NUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 09:20:20 -0400
In-Reply-To: <b25a477f-0bb1-979e-1bfe-a8b35dc0d289@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 27/05/16 13:03, Alexander Aring wrote:
> Hi,
>
> On 05/27/2016 12:05 PM, Stefan Schmidt wrote:
>> Hello.
>>
>> On 23/05/16 21:22, Alexander Aring wrote:
>>> In case of sending RA messages we need some way to get the short address
>>> from an 802.15.4 6LoWPAN interface. This patch will add a temporary
>>> debugfs entry for experimental userspace api.
>>>
>>> Signed-off-by: Alexander Aring<aar@pengutronix.de>
>>> ---
>>>    net/6lowpan/debugfs.c | 35 +++++++++++++++++++++++++++++++++++
>>>    1 file changed, 35 insertions(+)
>>>
>>> diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c
>>> index acbaa3d..638ae59 100644
>>> --- a/net/6lowpan/debugfs.c
>>> +++ b/net/6lowpan/debugfs.c
>>> @@ -245,6 +245,37 @@ static const struct file_operations lowpan_context_fops = {
>>>        .release    = single_release,
>>>    };
>>>    +static int lowpan_short_addr_get(void *data, u64 *val)
>>> +{
>>> +    struct wpan_dev *wdev = data;
>>> +
>>> +    rtnl_lock();
>>> +    *val = le16_to_cpu(wdev->short_addr);
>>> +    rtnl_unlock();
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +DEFINE_SIMPLE_ATTRIBUTE(lowpan_short_addr_fops, lowpan_short_addr_get,
>>> +            NULL, "0x%04llx\n");
>>> +
>>> +static int lowpan_dev_debugfs_802154_init(const struct net_device *dev,
>>> +                      struct lowpan_dev *ldev)
>>> +{
>>> +    struct dentry *dentry;
>>> +
>>> +    if (!lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154))
>>> +        return 0;
>>> +
>>> +    dentry = debugfs_create_file("short_addr", 0444, ldev->iface_debugfs,
>>> +                     lowpan_802154_dev(dev)->wdev->ieee802154_ptr,
>>> +                     &lowpan_short_addr_fops);
>>> +    if (!dentry)
>>> +        return -EINVAL;
>>> +
>>> +    return 0;
>>> +}
>>> +
>>>    int lowpan_dev_debugfs_init(struct net_device *dev)
>>>    {
>>>        struct lowpan_dev *ldev = lowpan_dev(dev);
>>> @@ -272,6 +303,10 @@ int lowpan_dev_debugfs_init(struct net_device *dev)
>>>                goto remove_root;
>>>        }
>>>    +    ret = lowpan_dev_debugfs_802154_init(dev, ldev);
>>> +    if (ret < 0)
>>> +        goto remove_root;
>>> +
>>>        return 0;
>>>      remove_root:
>> Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>
>>
> grml, I changed this patch now to have an 802154/short_addr directory
> inside the root of 6lowpan debugfs entry.
>
> This is because Michael Richardson wrote that other L2 has also
> short_addr (any kind of second L2 address type), see [0].

The question is if we ever will have support for them in Linux. But I 
agree that it might be better to have an architecture that would fit for 
those cases as well.

> Each of them has their own "constraints" e.g. 802.15.4 2-byte length, or
> sometimes 1-byte. This constraint depends on L2, so I added 802154
> subdir.

OK

regards
Stefan Schmidt
