From: Pavel Emelianov <xemul@sw.ru>
Subject: Re: [PATCH] Rework dev_base via list_head
Date: Thu, 03 May 2007 14:42:12 +0400
Message-ID: <4639BC84.5040807@sw.ru>
References: <463894E8.6090204@sw.ru> <20070503.032540.101470158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@sw.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:1251 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161823AbXECKhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 06:37:21 -0400
In-Reply-To: <20070503.032540.101470158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pavel Emelianov <xemul@sw.ru>
> Date: Wed, 02 May 2007 17:40:56 +0400
> 
>> Cleanup of dev_base list use, with the aim to simplify making
>> device list per-namespace. In almost every occasion, use of
>> dev_base variable and dev->next pointer could be easily replaced
>> by  for_each_netdev loop. A few most complicated places were
>> converted to using first_netdev()/next_netdev().
>>
>> Fits 2.6.21-rc7 tree.
>>
>> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
>> Acked-by: Kirill Korotaev <dev@openvz.org>
> 
> Overall this looks mostly good.
> 
> One thing I want to audit before applying this is
> loop termination conditions.
> 
> With the old loop, if you do something like this:
> 
> 	for (dev = dev_base; dev; dev = dev->next) {
> 		if (dev == what_I_want)
> 			break;
> 	}
> 
> you can test for a successful find after the loop with:
> 
> 	if (dev) {
> 		I_found_it();
> 	}
> 
> That doesn't work with for_each_netdev(), if the loop
> runs till the end of the list, the iterator will not
> be left at NULL.
> 
> I just want to make sure you didn't leave any code around which wants
> that behavior still.

My fault :( I've found some places where this was missed.
I will make a new patch shortly.

> This is one of the subtle things about using the list iterators in
> linux/list.h, vs. a traditional by-hand singly linked list
> implementation.
> 

