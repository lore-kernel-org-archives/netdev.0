From: Xiaotian Feng <dfeng@redhat.com>
Subject: Re: [RFC PATCH net-next] net: rename group sysfs entry to netdev_group
Date: Thu, 10 Feb 2011 10:54:35 +0800
Message-ID: <4D53536B.2010505@redhat.com>
References: <1297248769-28530-1-git-send-email-dfeng@redhat.com>	<20110209.140323.39178091.davem@davemloft.net> <20110209.140558.59676278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090002070800090806030504"
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	therbert@google.com, ebiederm@xmission.com, shemminger@vyatta.com,
	ddvlad@rosedu.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753495Ab1BJCyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 21:54:50 -0500
In-Reply-To: <20110209.140558.59676278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090002070800090806030504
Content-Type: text/plain; charset=ISO-8859-7; format=flowed
Content-Transfer-Encoding: 8bit

On 02/10/2011 06:05 AM, David Miller wrote:
> From: David Miller<davem@davemloft.net>
> Date: Wed, 09 Feb 2011 14:03:23 -0800 (PST)
>
>> From: Xiaotian feng<dfeng@redhat.com>
>> Date: Wed,  9 Feb 2011 18:52:49 +0800
>>
>>> From: Xiaotian Feng<dfeng@redhat.com>
>>>
>>> commit a512b92 adds sysfs entry for net device group, but
>>> before this commit, tun also uses group sysfs, so after this
>>> commit checkin, kernel warns like this:
>>>      sysfs: cannot create duplicate filename '/devices/virtual/net/vnet0/group'
>>>
>>> Since tun has used this for years, rename sysfs under tun might
>>> break existing userspace, so rename group sysfs entry for net device
>>> group is a better choice.
>>>
>>> Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
>>
>> I don't think we have much choice in this matter, so I have applied
>> this patch, thanks!
>
> Wait, you didn't even build test this patch?!?!?!?!
>
> net/core/net-sysfs.c: In function ¡format_netdev_group¢:
> net/core/net-sysfs.c:298: error: ¡const struct net_device¢ has no member named ¡netdev_group¢
> net/core/net-sysfs.c: At top level:
> net/core/net-sysfs.c:333: error: ¡show_group¢ undeclared here (not in a function)
>
> "RFC" doesn't preclude you from at least build testing patches you
> post.
>
> Sigh...
>
Sorry, my bad ... v2 patch is attatched, I've built and r/w this renamed 
sysfs, all work fine now. Sorry again about my carelessness ...

Regards
Xiaotian
>
>


--------------090002070800090806030504
Content-Type: text/plain;
 name="0001-net-rename-group-sysfs-entry-to-netdev_group.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-net-rename-group-sysfs-entry-to-netdev_group.patch"

>From 35388da8821a72a71f54cb955146a881f916eb25 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Thu, 10 Feb 2011 10:48:53 +0800
Subject: [PATCH net-next v2] net: rename group sysfs entry to netdev_group

commit a512b92 adds sysfs entry for net device group, but
before this commit, tun also uses group sysfs, so after this
commit checkin, kernel warns like this:
    sysfs: cannot create duplicate filename '/devices/virtual/net/vnet0/group'

Since tun has used this for years, rename sysfs under tun might
break existing userspace, so rename group sysfs entry for net device
group is a better choice.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Vlad Dogaru <ddvlad@rosedu.org>
---
 net/core/net-sysfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2e4a393..5ceb257 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -330,7 +330,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
-	__ATTR(group, S_IRUGO | S_IWUSR, show_group, store_group),
+	__ATTR(netdev_group, S_IRUGO | S_IWUSR, show_group, store_group),
 	{}
 };
 
-- 
1.7.1


--------------090002070800090806030504--
