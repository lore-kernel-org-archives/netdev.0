From: Xiao Jiang <jgq516@gmail.com>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Thu, 17 May 2012 10:23:55 +0800
Message-ID: <4FB4613B.3020603@gmail.com>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com> <CACVXFVNzmq74BKYZN1SpXYULneV2ASmniMhs4LhevPm-XgSJpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:65532 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760463Ab2EQBde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 21:33:34 -0400
In-Reply-To: <CACVXFVNzmq74BKYZN1SpXYULneV2ASmniMhs4LhevPm-XgSJpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei wrote:
> On Wed, May 16, 2012 at 4:01 PM,  <jgq516@gmail.com> wrote:
>   
>> From: Xiao Jiang <jgq516@gmail.com>
>>
>> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet devices
>> which possibly use "usb%d" names, add this flag to make sure pandaboard
>> can mount nfs with smsc95xx NIC.
>>     
>
> Without the flag, I also can mount nfs successfully on my Pandaboard...
>
>   
I have pulled latest tree 
(git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
commit 0e93b4b304ae052ba1bc73f6d34a68556fe93429), and enable related 
options (USB_NET_SMSC95XX,
USB_EHCI_HCD and USB_EHCI_HCD_OMAP) with omap2plus_config, However the 
kernel still can't mount
nfs, pls see below infos.

[    3.114105] smsc95xx v1.0.4
[    4.533752] smsc95xx 1-1.1:1.0: *eth0*: register 'smsc95xx' at 
usb-ehci-omap.0-1.1, smsc95xx USB 2.0 Ethernet, fe:b9:1b:07:8e:d1
[  108.854217] VFS: Unable to mount root fs via NFS, trying floppy.
[  108.861114] VFS: Cannot open root device "nfs" or unknown-block(2,0): 
error -6
[  108.868713] Please append a correct "root=" boot option; here are the 
available partitions:
[  108.877655] b300         7761920 mmcblk0  driver: mmcblk
[  108.883239]   b301           40131 mmcblk0p1 
00000000-0000-0000-0000-000000000mmcblk0p1
[  108.891662]   b302         7719232 mmcblk0p2 
00000000-0000-0000-0000-000000000mmcblk0p2
[  108.900146] Kernel panic - not syncing: VFS: Unable to mount root fs 
on unknown-block(2,0)

BTW: I tested it with OMAP4430 ES2.2 pandaboard, the issue can be solved 
with apply the patch.

Is there something which I missed? thanks.

Regards,
Xiao
>> Signed-off-by: Xiao Jiang <jgq516@gmail.com>
>> ---
>>  drivers/net/usb/smsc95xx.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
>> index 94ae669..e158288 100644
>> --- a/drivers/net/usb/smsc95xx.c
>> +++ b/drivers/net/usb/smsc95xx.c
>> @@ -1192,7 +1192,8 @@ static const struct driver_info smsc95xx_info = {
>>        .rx_fixup       = smsc95xx_rx_fixup,
>>        .tx_fixup       = smsc95xx_tx_fixup,
>>        .status         = smsc95xx_status,
>> -       .flags          = FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
>> +       .flags          = FLAG_ETHER | FLAG_POINTTOPOINT | FLAG_SEND_ZLP |
>> +                         FLAG_LINK_INTR,
>>  };
>>
>>  static const struct usb_device_id products[] = {
>> --
>> 1.7.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>     
>
>
> Thanks,
>   
