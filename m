From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 1/2] net: ipv6: af_inet6: Fix warning when CONFIG_SYSCTL=n
Date: Sat, 16 Nov 2013 13:22:56 -0500
Message-ID: <5287B800.40201@gmail.com>
References: <1384570328-21666-1-git-send-email-festevam@gmail.com> <5287B3E2.2030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f42.google.com ([209.85.128.42]:45908 "EHLO
	mail-qe0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab3KPSW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 13:22:59 -0500
Received: by mail-qe0-f42.google.com with SMTP id t9so335244qeq.29
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 10:22:58 -0800 (PST)
In-Reply-To: <5287B3E2.2030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2013 01:05 PM, Vlad Yasevich wrote:
> On 11/15/2013 09:52 PM, Fabio Estevam wrote:
>> From: Fabio Estevam <fabio.estevam@freescale.com>
>>
>> When CONFIG_SYSCTL=n the following build warning happens:
>>
>> net/ipv6/af_inet6.c:710:13: warning: 'ipv6_packet_cleanup' defined but not used [-Wunused-function]
>>
>> ipv6_packet_cleanup() is only used when CONFIG_SYSCTL=y, so protect its 
>> definition with an'ifdef CONFIG_SYSCTL'.
>>
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
>> ---
>>  net/ipv6/af_inet6.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
>> index ff75313..e4ad65c 100644
>> --- a/net/ipv6/af_inet6.c
>> +++ b/net/ipv6/af_inet6.c
>> @@ -707,10 +707,12 @@ static int __init ipv6_packet_init(void)
>>  	return 0;
>>  }
>>  
>> +#ifdef CONFIG_SYSCTL
>>  static void ipv6_packet_cleanup(void)
>>  {
>>  	dev_remove_pack(&ipv6_packet_type);
>>  }
>> +#endif
>>  
>>  static int __net_init ipv6_init_mibs(struct net *net)
>>  {
>>
> 
> NACK.  ipv6_packet_init and ipv6_packet_cleanup should in no way depend
> on sysctl.
> 
> -vlad
> 

It actually appears a bit worse then that.  Looks like the inet6_init()
error were a bit messed up after the introduction of ping socket support.

-vlad
