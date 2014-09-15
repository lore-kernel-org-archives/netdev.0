From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 1/4] openvswitch: refactor ovs flow extract API.
Date: Mon, 15 Sep 2014 10:23:40 -0700
Message-ID: <CALnjE+o9ibo15DfJaM29zkXjVMSGwgSJK_0+dr-zmMOuO0Bq+Q@mail.gmail.com>
References: <1410478084-1436-1-git-send-email-pshelar@nicira.com>
	<20140913.164708.1690675945507354047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:60069 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753544AbaIORXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 13:23:41 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so4323991igd.14
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 10:23:41 -0700 (PDT)
In-Reply-To: <20140913.164708.1690675945507354047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2014 at 1:47 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu, 11 Sep 2014 16:28:04 -0700
>
>> @@ -250,7 +251,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
>>       stats = this_cpu_ptr(dp->stats_percpu);
>>
>>       /* Extract flow from 'skb' into 'key'. */
>> -     error = ovs_flow_extract(skb, p->port_no, &key);
>> +     error = ovs_flow_key_extract(skb, &key);
>>       if (unlikely(error)) {
>>               kfree_skb(skb);
>>               return;
> ...
>> @@ -611,5 +604,35 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
>>               }
>>       }
>>
>> +     OVS_CB(skb)->pkt_key = key;
>>       return 0;
>
> Wow, have you really been putting pointers to kernel stack variables
> into the SKB control block all this time?
>
> That's error prone as well as asking for trouble.
>
Good point.

> Please adjust the code to not do this.

But this is significantly different than the patch series. If I change
this patch, I will need to change all patches in this series. So I
would add one patch at the end of this series to fix this issue.

Thanks,
Pravin.
