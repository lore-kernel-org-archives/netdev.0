From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Mon, 08 Jul 2013 12:59:08 -0700
Message-ID: <51DB1A0C.3080807@candelatech.com>
References: <51BF50B3.1080403@candelatech.com>      <1371493059.3252.200.camel@edumazet-glaptop>      <51D1C620.8030007@candelatech.com>     <1372813467.4979.46.camel@edumazet-glaptop>     <51D398C0.5060802@candelatech.com>    <1372826512.4979.49.camel@edumazet-glaptop>    <51D3AD66.8030506@candelatech.com>   <1372827749.4979.52.camel@edumazet-glaptop>   <51DAF5A7.60505@candelatech.com>  <1373307702.4979.116.camel@edumazet-glaptop>  <51DB054D.6060507@candelatech.com> <1373310119.4979.119.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48097 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab3GHT7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 15:59:09 -0400
In-Reply-To: <1373310119.4979.119.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2013 12:01 PM, Eric Dumazet wrote:
> On Mon, 2013-07-08 at 11:30 -0700, Ben Greear wrote:
>> On 07/08/2013 11:21 AM, Eric Dumazet wrote:
>>> On Mon, 2013-07-08 at 10:23 -0700, Ben Greear wrote:
>>>
>>>> We ran a 5+ day test using un-modified 3.10 kernel and did not trigger
>>>> the bug.
>>>
>>> Using wired ethernet only, or any kind of adapters, including ath9k ?
>>
>> Exact same hardware and configuration:
>>
>> ath9k, around 240 wifi
>> stations trying to connect to APs that can handle a bit less
>> than 240 total, starting TCP traffic when stations are connected.
>> It appears that the constant churn of stations going up and down
>> is key, but of course that is par for the course, especially in
>> the wifi stack.
>>
>> Some of our local wifi patches make the system work considerably faster when
>> we have hundreds of wifi stations, so timing will be different on upstream
>> kernels, and of course we could have bugs :)
>
> There is this thing in ath9k about aggregating two frags
>
> drivers/net/wireless/ath/ath9k/recv.c line 1298 contains :
>
> RX_STAT_INC(rx_frags);
>
> Could you check these stats (I do not know if they are reported by
> ethtool -S or another debugging facility) and check if rx_frags is ever
> increasing ?

They are in debugfs, and they appear to increase fairly often, for
instance:

[root@lec2010-ath9k-1 lanforge]# cat /debug/ieee80211/wiphy0/ath9k/recv|tail -5
            RX-Pkts-All :  288009442
           RX-Bytes-All : 4067932166
             RX-Beacons :   14826735
               RX-Frags :       3944
            RX-Spectral :          0

I don't have the stats from the system that reproduced the bug
(it has been rebooted), but if I do see the bug again, I'll
grab the rx-frags and other stats just in case it shows
some anomaly.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
