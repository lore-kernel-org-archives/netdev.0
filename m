From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH] ipvs: Make the synchronization interval controllable
Date: Thu, 7 Feb 2008 00:12:58 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802062329150.15729@titan.stealer.net>
References: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net>
 <alpine.DEB.1.00.0802061409130.7879@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:43026 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764277AbYBFXNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 18:13:10 -0500
In-Reply-To: <alpine.DEB.1.00.0802061409130.7879@chino.kir.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Feb 2008, David Rientjes wrote:

> On Wed, 6 Feb 2008, Sven Wegener wrote:
>
>> diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
>> index 948378d..9b57ad3 100644
>> --- a/net/ipv4/ipvs/ip_vs_sync.c
>> +++ b/net/ipv4/ipvs/ip_vs_sync.c
>> @@ -143,6 +143,8 @@ char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
>>  /* multicast addr */
>>  static struct sockaddr_in mcast_addr;
>>
>> +/* milliseconds between synchronization runs */
>> +int sysctl_ip_vs_sync_interval = 1000;
>>
>>  static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
>>  {
>
> How useful is a negative ip_vs_sync_interval?

Negative values will be converted to MAX_JIFFY_OFFSET by msecs_to_jiffies 
and result in a very long interval. A too long interval will be a good way 
to get your system OOM. We could use an unsigned int or even restrict the 
value with proc_dointvec_minmax. I'd prefer the latter, that's what I 
already had in my mind and it also protects from unintentionally choosing 
a too long interval.

Sven
