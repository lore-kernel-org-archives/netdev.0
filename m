From: dingtianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: add synchronize_net() after netdev_rx_handler_unregister
Date: Thu, 23 May 2013 09:43:46 +0800
Message-ID: <519D7452.8050405@huawei.com>
References: <519C8504.1080906@huawei.com> <519D0EBB.4030307@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:64439 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757447Ab3EWBrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 21:47:41 -0400
In-Reply-To: <519D0EBB.4030307@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/5/23 2:30, Sergei Shtylyov wrote:
> Hello.
> 
> On 22-05-2013 12:42, dingtianhong wrote:
> 
>> commit 00cfec3748 (net: add a synchronize_net() ...) add a synchronize_net()
> 
>    Please specify complete summary line of this commit.
> 

ok, I will modify and send again, just tell me your opinion, thanks.

>> in netdev_rx_handler_unregister() to guarantee the rx_handler  is NULL when
>> rx_handler_data is a non NULL in rcu_read_lock().
>>
>> so the caller should not use netdev_rx_handler_unregister in atomic as it may
>> schedule and sleep, the commit fcd99434f
> 
>    You forgot to specify the summary line of this commit.
> 
>> fix the bug in bond release, but the
>> problem is no action to guarantee the rx_handler_data is NULL when bond release,
>> so add synchronize_net() and fix it.
> 
>> This patch adds more comments to netdev_rx_handler_unregister().
> 
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> WBR, Sergei
> 
> 
> 
