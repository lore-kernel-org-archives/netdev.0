From: Curtis Doty <Curtis@GreenKey.net>
Subject: Re: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1
Date: Fri, 18 May 2007 16:18:30 -0700 (PDT)
Message-ID: <20070518231830.9202A6F0C1@alopias.GreenKey.net>
References: <464E29C8.9090905@redhat.com> <464E30B7.3030107@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alopias.GreenKey.net ([209.209.60.60]:34086 "EHLO
	alopias.GreenKey.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768AbXERXSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 19:18:31 -0400
In-Reply-To: <464E30B7.3030107@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

4:03pm Kok, Auke said:

> Chuck Ebbert wrote:
>>  We have several reports now of hitting this assertion in
>>  netif_rx_complete(), inlined in e1000_clean():
>>
>>          BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
>>
>>   [<c0431162>] __queue_work+0x51/0x5e
>>   [<c059eea1>] et_rx_action+0x94/0x185
>>   [<c042837d>] __do_softirq+0x5d/0xba
>>   [<c0407837>] do_softirq+0x59/0xb1
>>   [<c04281e9>] local_bh_enable_ip+0x35/0x40
>>   [<c059e46b>] dev_open+0x44/0x62
>>   [<c059ce8c>] dev_change_flags+0x46/0xe3
>>   [<c05d9e09>] devinet_ioctl+0x250/0x56a
>>
>>  The second function is "net_rx_action", corrupted
>>  by the serial connection.
>>  The source file has four extra lines at the top because of a
>>  trivial wireless patch, so 898 in that code is really 894 in
>>  the stock kernel.
>
> please shared that code then.
>

http://cvs.fedora.redhat.com/viewcvs/devel/kernel/linux-2.6-wireless.patch

