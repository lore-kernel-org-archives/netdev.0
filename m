From: Alexander Holler <holler@ahsoftware.de>
Subject: connector and netlink_broadcast (semop failed for cookie ...)
Date: Mon, 05 Nov 2012 20:42:32 +0100
Message-ID: <509816A8.70005@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've recently enabled CONFIG_CONNECTOR in kernel 3.6.6 and now I've got 
the message "semop failed for cookie ..." when using cryptsetup (I've 
never got that error before).

A short search revealed the following discussion about ignoring errors 
from netlink_broadcast_filtered(): https://lkml.org/lkml/2011/8/19/60

connector doesn't use netlink_broadcast_filtered() directly but it 
returns netlink_broadcast() in cn_netlink_send() while 
netlink_broadcast() just is a wrapper around netlink_broadcast_filtered().

Could it be the case that cn_netlink_send() has to ignore the same 
return codes as done in kobject_uevent_env()? Or maybe the users of 
cn_netlink_send() have to ignore them?

Regards,

Alexander
