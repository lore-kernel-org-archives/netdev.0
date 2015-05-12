From: poma <pomidorabelisima@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Tue, 12 May 2015 02:13:28 +0200
Message-ID: <555145A8.8010003@gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>	 <20150504133943.GA17043@x131e>	 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>	 <20150504132714.55dca5b0@urahara>	 <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>	 <20150511131516.GC10375@x131e> <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Dominick Grift <dac.override@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33772 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbbELANc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 20:13:32 -0400
Received: by wgin8 with SMTP id n8so146094186wgi.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 17:13:31 -0700 (PDT)
In-Reply-To: <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.05.2015 16:53, Eric Dumazet wrote:
> On Mon, 2015-05-11 at 15:15 +0200, Dominick Grift wrote:
>> On Mon, May 04, 2015 at 02:35:27PM -0700, Cong Wang wrote:
>>
>> <snip>
>>
>>> It _looks like_ we only retrieve vlan info to fill netlink
>>> messages in timer context, so it doesn't seem we need to
>>> hold br->lock here.
>>>
>>> But I never look into br vlan code of course.
>>
>> This is just a friendly reminder that this issue still exits in: 4.1.0-0.rc2.git3.1
>>
>> Ignore me if you are aware of the above
>>
> 
> Hi Dominick
> 
> Have you tried this patch I sent last monday ?
> 

https://bugzilla.kernel.org/show_bug.cgi?id=98081#c2


> I will submit formally when I get a test result.
> 
> Thanks
> 
> diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
> index 4fcaa67750fda845ad0a180332c4cd96a9524086..7caf7fae2d5b8aa369b924e1c87a47c343fb8954 100644
> --- a/net/bridge/br_stp_timer.c
> +++ b/net/bridge/br_stp_timer.c
> @@ -97,7 +97,9 @@ static void br_forward_delay_timer_expired(unsigned long arg)
>  		netif_carrier_on(br->dev);
>  	}
>  	br_log_state(p);
> +	rcu_read_lock();
>  	br_ifinfo_notify(RTM_NEWLINK, p);
> +	rcu_read_unlock();
>  	spin_unlock(&br->lock);
>  }
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
