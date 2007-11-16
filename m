From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Fri, 16 Nov 2007 11:18:16 +0800
Message-ID: <473D0BF8.3060902@cn.fujitsu.com>
References: <473D0482.4050705@cn.fujitsu.com> <20071115.185403.138420969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:57779 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755429AbXKPDUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:20:38 -0500
In-Reply-To: <20071115.185403.138420969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller said the following on 2007-11-16 10:54:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 16 Nov 2007 10:46:26 +0800
> 
>> The current kernel doesn't verify the udp checksum if user doesn't set a
>> socket filter.It's fine for LAN. But for WAN, it's not a good option.
>> Shall we fix it? Below is the patch to make udp checksum be always 
>> available.
>>
>> [IPV4] UDP: Always checksum even if without socket filter
>> Make udp checksum be always available even if without socket filter.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> It checks the checksum in udp_recvmsg() and udp_poll().
> 

Actually, I tested and found this issue.
I sent 50 udp packets, which have wrong checksum, to my
machine.
Before the patch being applied, /proc/net/snmp's udp
InDatagrams increased, and InErrors didn't increase.
After the patch being applied, InErrors increased correctly
and InDatagrams stayed unchanging.

So, I think the checksum in udp_queue_rcv_skb() actually does
the work, not that in udp_recvmsg() and udp_poll().

If I am wrong, please point out.

> Please do not fix bugs via code inspection without writing
> test programs to validate whether there is really a "bug"
> here or not.
> 

This is a bug from test, not from code inspection.

