From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv4/route: arg delay is useless in rt_cache_flush()
Date: Fri, 07 Sep 2012 12:41:59 +0200
Message-ID: <5049CF77.2060408@6wind.com>
References: <1347010284-3419-1-git-send-email-nicolas.dichtel@6wind.com> <1347013794.2484.488.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36581 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514Ab2IGKmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 06:42:05 -0400
Received: by eekc1 with SMTP id c1so1101988eek.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 03:42:04 -0700 (PDT)
In-Reply-To: <1347013794.2484.488.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/09/2012 12:29, Eric Dumazet a =C3=A9crit :
> On Fri, 2012-09-07 at 11:31 +0200, Nicolas Dichtel wrote:
>> Since route cache deletion (89aef8921bfbac22f), delay is no
>> more used. Remove it.
>>
> ...
>
>>   #ifdef CONFIG_SYSCTL
>> @@ -2354,16 +2350,12 @@ static int ipv4_sysctl_rtcache_flush(ctl_tab=
le *__ctl, int write,
>>   					size_t *lenp, loff_t *ppos)
>>   {
>>   	if (write) {
>> -		int flush_delay;
>>   		ctl_table ctl;
>>   		struct net *net;
>>
>>   		memcpy(&ctl, __ctl, sizeof(ctl));
>> -		ctl.data =3D &flush_delay;
>> -		proc_dointvec(&ctl, write, buffer, lenp, ppos);
>> -
>>   		net =3D (struct net *)__ctl->extra1;
>> -		rt_cache_flush(net, flush_delay);
>> +		rt_cache_flush(net);
>>   		return 0;
>>   	}
>>
>
> Why do you keep ctl then ?
>
> 	if (write) {
> 		rt_cache_flush((struct net *)__ctl->extra1);
> 		return 0;
> 	}
>
>
Right, there is no reason.


Regards,
Nicolas
