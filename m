From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2] ipv6: Kill ipv6 dependency of icmpv6_send().
Date: Thu, 25 Apr 2013 13:13:54 -0700
Message-ID: <CALnjE+pR_z9E3Qz_C9xZiLh7f2Genc8rvZCWRUDvP-0TSkxX7w@mail.gmail.com>
References: <1366915075-1538-1-git-send-email-pshelar@nicira.com>
	<1366916924.8964.177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:34861 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932882Ab3DYUN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 16:13:58 -0400
Received: by mail-ve0-f199.google.com with SMTP id m1so2849768ves.6
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 13:13:54 -0700 (PDT)
In-Reply-To: <1366916924.8964.177.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 25, 2013 at 12:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-04-25 at 11:37 -0700, Pravin B Shelar wrote:
>
>> +int inet6_register_icmp_sender(ip6_icmp_send_t *fn)
>> +{
>> +     return (cmpxchg(&ip6_icmp_send, NULL, fn) == NULL) ? 0 : -EBUSY;
>> +}
>> +EXPORT_SYMBOL(inet6_register_icmp_sender);
>> +
>> +int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn)
>> +{
>> +     int ret;
>> +
>> +     ret = (cmpxchg(&ip6_icmp_send, fn, NULL) == fn) ? 0 : -EINVAL;
>> +
>> +     synchronize_net();
>> +
>> +     return ret;
>> +}
>> +EXPORT_SYMBOL(inet6_unregister_icmp_sender);
>
> Good idea, but I bet you didn't run sparse on this code...
>
> CONFIG_SPARSE_RCU_POINTER=y
>
> make C=2 net/ipv6/ip6_icmp.o
>
> you probably need to cast to (ip6_icmp_send_t *)
>
right, Let me send fix for it.
>
