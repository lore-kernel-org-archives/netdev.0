From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 07 Feb 2012 17:37:51 +0400
Message-ID: <4F31292F.2090503@parallels.com>
References: <20120107.121339.633839797125273714.davem@davemloft.net> <20120207121256.50667809@destiny.ordissimo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Anisse Astier <anisse@astier.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12495 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755965Ab2BGNiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 08:38:02 -0500
In-Reply-To: <20120207121256.50667809@destiny.ordissimo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> index 1a8f93b..43e1439 100644
>> --- a/net/ipv4/Kconfig
>> +++ b/net/ipv4/Kconfig
>> @@ -410,8 +410,12 @@ config INET_TCP_DIAG
>>  	def_tristate INET_DIAG
>>  
>>  config INET_UDP_DIAG
>> +	tristate "UDP: socket monitoring interface"
>>  	depends on INET_DIAG
>> -	def_tristate INET_DIAG && IPV6
> This broke earlier patch 
> b872a2371ffd13e6d83423ef621a707df4c158ac "udp_diag: Make it module when ipv6 is a module",
> which brings back the compilation error when compiling linus master (v3.3-rc2+):
> 
> net/built-in.o: In function `udp_dump_one':
> udp_diag.c:(.text+0x59852): undefined reference to `__udp6_lib_lookup'
> 
> 
>> +	default n
>> +	---help---
>> +	  Support for UDP socket monitoring interface used by the ss tool.
>> +	  If unsure, say Y.
>>  

I assume you have CONFIG_IPV6=m and CONFIG_INET_UDP_DIAG=y, right?
This one should fix the issue, you'll not be able to set it to Y when
IPV6 is M.


[PATCH] udp_diag: Add dependency on IPV6

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index aa2a2c7..55d39a4 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -409,7 +409,7 @@ config INET_TCP_DIAG
 
 config INET_UDP_DIAG
 	tristate "UDP: socket monitoring interface"
-	depends on INET_DIAG
+	depends on INET_DIAG && IPV6
 	default n
 	---help---
 	  Support for UDP socket monitoring interface used by the ss tool.
