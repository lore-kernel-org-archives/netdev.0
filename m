From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Sun, 20 Jan 2013 18:52:36 +0100
Message-ID: <50FC2EE4.3080705@gmail.com>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, stefanr@s5r6.in-berlin.de,
	davem@davemloft.net
To: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:53769 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442Ab3ATRwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 12:52:40 -0500
Received: by mail-bk0-f50.google.com with SMTP id jf3so2687427bkc.9
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 09:52:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've implemented IPv6 over firewire. Right now I'm facing the problem 
that the corresponding RFC3146 requires very firewire specific 
information sent during neighborhood discovery.

There was already a discussion on the linux1394 mailing list 
(http://sourceforge.net/mailarchive/message.php?msg_id=30342089 and 
http://sourceforge.net/mailarchive/forum.php?thread_name=50E4A3E5.8080304%40gmail.com&forum_name=linux1394-devel) 


During that discussion all participants agreed that it makes no sense to 
introduce a dependency between the ndisc code and the firewire net driver.

So the most appealing option seems to be to introduce on more callback 
routine either in struct net_device or struct net_device_ops:

int (*ndo_fill_llao)(void *llao);

Because I'm not so familiar with the structure of the whole network 
infrastructure in Linux, I need some advice if struct net_device or 
struct net_device_ops is the right place.

Maybe it's worth to generalize this and do the same for IPv4/ARP because 
right now the ARP packets are mangled in the firewire net driver.

Nevertheless, I've to admit that right now it seems that only IPv6 over 
firewire requires such a callback routine.


Regards,

Stephan
