From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Thu, 21 May 2015 15:22:16 -0400
Message-ID: <CA+5PVA70p=y_62fkEG6OU=+-QpLX-SFi_mZ3UNgA4nu7GmvwcQ@mail.gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	<20150504133943.GA17043@x131e>
	<CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	<20150504132714.55dca5b0@urahara>
	<CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
	<20150511131516.GC10375@x131e>
	<1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150512182741.GD9693@x131e>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Dominick Grift <dac.override@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33724 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076AbbEUTWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 15:22:17 -0400
Received: by qkgv12 with SMTP id v12so63941435qkg.0
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 12:22:16 -0700 (PDT)
In-Reply-To: <20150512182741.GD9693@x131e>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 2:27 PM, Dominick Grift <dac.override@gmail.com> wrote:
> On Mon, May 11, 2015 at 07:53:06AM -0700, Eric Dumazet wrote:
>>
>> Hi Dominick
>>
>> Have you tried this patch I sent last monday ?
>>
>> I will submit formally when I get a test result.
>>
>> Thanks
>
> Eric,
>
> I have tested the below patch and everything is in order!
>
> Thank you!
>
>>
>> diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
>> index 4fcaa67750fda845ad0a180332c4cd96a9524086..7caf7fae2d5b8aa369b924e1c87a47c343fb8954 100644
>> --- a/net/bridge/br_stp_timer.c
>> +++ b/net/bridge/br_stp_timer.c
>> @@ -97,7 +97,9 @@ static void br_forward_delay_timer_expired(unsigned long arg)
>>               netif_carrier_on(br->dev);
>>       }
>>       br_log_state(p);
>> +     rcu_read_lock();
>>       br_ifinfo_notify(RTM_NEWLINK, p);
>> +     rcu_read_unlock();
>>       spin_unlock(&br->lock);
>>  }
>>
>>
>>

I'm still seeing this with Linus' tree as of yesterday.  Is this
queued anywhere for 4.1?

josh
