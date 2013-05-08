From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Linux driver for Realtek RTL8723AU devices with USB ID 0bda:1724
 such as found in Lenovo IdeaPad Yoga 13
Date: Wed, 08 May 2013 11:06:44 -0500
Message-ID: <518A7814.1070604@lwfinger.net>
References: <5159B52D.3050601@lwfinger.net> <5189B939.4010905@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Dan Williams <dcbw@redhat.com>,
	'George0505' <george0505@realtek.com>,
	Joon Ro <joonhyoung.ro@gmail.com>,
	Greg KH <gregkh@linux-foundation.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:41308 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758385Ab3EHQGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 12:06:48 -0400
In-Reply-To: <5189B939.4010905@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2013 09:32 PM, H. Peter Anvin wrote:
>
> So I can verify that this driver works against 3.8.11 (not against
> current -linus because of a build failure), and yes, there is Bluetooth
> in this device.  In fact, it seems to work better than some in-tree
> drivers I have seen in the past.
>
> However, I'm confused as to the above and what it implies for the
> purpose of the staging tree.  Wasn't the whole point of the staging tree
> to have a working-but-ugly driver upstream and have the work to clean it
> up happen in the mainline tree instead of off somewhere.

Yes, but even staging has some standards. For example, they frown on inclusion 
of firmware in a massive data block in a file in the driver - it should be in a 
separate file the /lib/firmware/ tree. In addition, the mainline 
drivers/net/wireless/ tree is only available to devices that use mac80211 for 
the software-based MAC layer. That conversion is a serious effort that may never 
be done, thus the 8723au driver may never leave staging.

What are the details of the build failure on the mainline tree? It builds fine 
here. One possibility is that your source tree has a leftover copy of 
include/linux/version.h that contains a stale coded value of the kernel version. 
I just pushed a Makefile fix that causes the compiler to look in the new 
location for version.h first. If that doesn't work, please post the error.

Larry
