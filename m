From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] switchdev: select INET in Kconfig
Date: Wed, 11 Mar 2015 14:14:18 -0400 (EDT)
Message-ID: <20150311.141418.155308296302669143.davem@davemloft.net>
References: <CAADnVQ+vnKJ=KHvMdy2f_82r=d7dS9HuNXKJt6=vMgjY0OE+Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, f.fainelli@gmail.com,
	sfeldma@gmail.com, rdunlap@infradead.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbbCKSOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 14:14:25 -0400
In-Reply-To: <CAADnVQ+vnKJ=KHvMdy2f_82r=d7dS9HuNXKJt6=vMgjY0OE+Ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 11 Mar 2015 08:36:16 -0700

> On Wed, Mar 11, 2015 at 2:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This would fix randconfig compile error:
>> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
>> (.text+0xf7811): undefined reference to `fib_flush_external'
>>
>> Also it fixes following warning:
>> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
>>
>> Suggested-by: Randy Dunlap <rdunlap@infradead.org>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/switchdev/Kconfig | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/switchdev/Kconfig b/net/switchdev/Kconfig
>> index 86a47e1..3487940 100644
>> --- a/net/switchdev/Kconfig
>> +++ b/net/switchdev/Kconfig
>> @@ -4,7 +4,7 @@
>>
>>  config NET_SWITCHDEV
>>         bool "Switch (and switch-ish) device support (EXPERIMENTAL)"
>> -       depends on INET
>> +       select INET
> 
> I believe Dave mentioned few times that 'select' is highly
> discouraged, since it doesn't work recursively.

Yes, the problem is that INET is not a leaf node.  It selects
CRYPTO stuff.
