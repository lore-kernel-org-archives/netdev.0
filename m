From: Fredrick <fjohnber@zoho.com>
Subject: yield() in netlink_broadcast_filtered
Date: Fri, 06 Apr 2012 07:11:56 -0700
Message-ID: <4F7EF9AC.8050305@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender1.zohomail.com ([72.5.230.103]:58469 "EHLO
	sender1.zohomail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381Ab2DFOb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 10:31:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



I see there is a yield being called from
netlink_broadcast_filtered.
.....
int netlink_broadcast_filtered(...)
{
....
         if (info.delivered) {
                 if (info.congested && (allocation & __GFP_WAIT))
                         yield();
                 return 0;
         }
         return -ESRCH;
}
.....

But I don't see the point of calling it.
After the yield, there is nothing being done.
It just returns. So why yield ?
Why can't it simply return?


-Fredrick
