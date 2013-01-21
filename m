From: Jason Wang <jasowang@redhat.com>
Subject: Re: surprising memory request
Date: Mon, 21 Jan 2013 13:21:49 +0800
Message-ID: <50FCD06D.9060000@redhat.com>
References: <20130118085818.147220.FMU5901@air.gr8dns.org>  <1358531190.11051.402.camel@edumazet-glaptop> <1358531673.11051.420.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Dirk Hohndel <dirk@hohndel.org>, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583Ab3AUFV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 00:21:56 -0500
In-Reply-To: <1358531673.11051.420.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2013 01:54 AM, Eric Dumazet wrote:
> On Fri, 2013-01-18 at 09:46 -0800, Eric Dumazet wrote:
>
>> Thats because Jason thought that tun device had to have an insane number
>> of queues to get good performance.
>>
>> #define MAX_TAP_QUEUES 1024
>>
>> Thats crazy if your machine has say 8 cpus.
>>
>> And Jason didnt care to adapt the memory allocations done in
>> alloc_netdev_mqs(), in order to switch to vmalloc() when kmalloc()
>> fails.
> I suggest using the more reasonable :
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index c81680d..ec18fbf 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -113,7 +113,7 @@ struct tap_filter {
>   * the order of 100-200 CPUs so this leaves us some breathing space if we want
>   * to match a queue per guest CPU.
>   */
> -#define MAX_TAP_QUEUES 1024
> +#define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
>  
>  #define TUN_FLOW_EXPIRE (3 * HZ)
>  

But it's default value 8 is a little too small, we can easily have a kvm
guest with more than 8 vcpus and a host multiqueue card with more than 8
queues. Maybe we can use num_possible_cpus() or just an arbitrary number
such as 256 which seems large enough.


>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
