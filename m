From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [RFCv2 bluetooth-next 1/3] 6lowpan: add debugfs support
Date: Thu, 26 Nov 2015 12:07:32 +0100
Message-ID: <5656E7F4.90009@osg.samsung.com>
References: <1447799594-6050-1-git-send-email-alex.aring@gmail.com>
 <1447799594-6050-2-git-send-email-alex.aring@gmail.com>
 <5655E4F8.3050900@osg.samsung.com> <20151125180049.GA4652@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de, mcr@sandelman.ca,
	lukasz.duda@nordicsemi.no, martin.gergeleit@hs-rm.de
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:58957 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698AbbKZLHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2015 06:07:46 -0500
In-Reply-To: <20151125180049.GA4652@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25/11/15 19:00, Alexander Aring wrote:
> Hi,
>
> On Wed, Nov 25, 2015 at 05:42:32PM +0100, Stefan Schmidt wrote:
>> Hello.
>>
>> On 17/11/15 23:33, Alexander Aring wrote:
>>> This patch will introduce a 6lowpan entry into the debugfs if enabled.
>>> Inside this 6lowpan directory we create a subdirectories of all 6lowpan
>>> interfaces to offer a per interface debugfs support.
> ...
>
>>>   static void lowpan_dellink(struct net_device *ldev, struct list_head *head)
>>> @@ -180,6 +187,7 @@ static void lowpan_dellink(struct net_device *ldev, struct list_head *head)
>>>   	ASSERT_RTNL();
>>>   	wdev->ieee802154_ptr->lowpan_dev = NULL;
>>> +	lowpan_netdev_unsetup(ldev);
>>>   	unregister_netdevice(ldev);
>>>   	dev_put(wdev);
>>>   }
>> If you are going to change the th uninit to exit and the unsetup to teardown
>> you can add my review.
>>
>> Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
>>
> I will add a patch which introduce the two functions:
>
> lowpan_register_netdevice - register_netdevice (without rtnl lock)
> lowpan_register_netdev - register_netdev (with rtnl lock)
>
> These two functions will call register_netdevice/register_netdev and 6lowpan
> debugfs init.
>
>
> I will remove the lowpan_netdev_unsetup function and introduce a:
>
> lowpan_unregister_netdevice - unregister_netdevice
>
> which calls unregister_netdevice and lowpan_dev_debugfs_exit. I will
> change the uninit to exit.
>
> Then we keep the same naming stuff like netdev and these function should
> always called when doing register_netdev/unregister_netdev for all
> lowpan interface.
>
> Then we can also move lowpan_netdev_setup before register_netdev. This
> will move more functionality which should be the same on all lowpan
> interfaces into the net/6lowpan branch.

Sounds good to me.

regards
Stefan Schmidt
