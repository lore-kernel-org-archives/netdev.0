From: Rafa Corvillo <rafael.corvillo@aoifes.com>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Thu, 27 Apr 2017 14:05:51 +0200
Message-ID: <5901DE9F.1070005@aoifes.com>
References: <58F9FD64.80506@aoifes.com> <20170425082741.59428876@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay-01-4.dondominio.net ([31.214.176.27]:33045 "EHLO
        smtp-relay-01-4.dondominio.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1161890AbdD0MFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 08:05:55 -0400
In-Reply-To: <20170425082741.59428876@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/17 17:27, Stephen Hemminger wrote:
> On Fri, 21 Apr 2017 14:39:00 +0200
> Rafa Corvillo <rafael.corvillo@aoifes.com> wrote:
>
>> We are working in an ARMv7 embedded system running kernel 4.9 (LEDE build).
>> It is an imx6 board with 2 ethernet interfaces. One of them is connected to
>> a Marvell switch.
>>
>> The schema of the system is the following:
>>
>>    +-------------------+ eth0
>>    |                   +--+
>>    |                   |  |
>>    | Embedded system   +--+
>>    |                   |
>>    |      ARMv7        |
>>    |                   | Marvell 88E8057(sky2) +-------------+
>>    |                   +--+ +--+             +--+ eth1
>>    |                   |  +---------------------+ |             |  +------+
>>    |                   +--+      CPU port       +--+ mv88e6176  +--+
>>    +------+--+---------+ |             |
>> emulated|  | |             |
>> GPIO    +--+ +--+             +--+ eth2
>> MDIO      +-----------------------------------+ |             |  +------+
>>                                 MDIO +--+             +--+
>> +-------------+
>>
>> There is a bridge (br-lan) which includes eth0/eth1/eth2
>>
>> If I connect the eth1/eth2, the link is up and I can do ping through it.
>> But, once
>> I start sending a heavy traffic load the link fails and the kernel sends the
>> following messages:
>>
>> [   48.557140] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   48.564964] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   48.572110] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   48.579263] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   48.586417] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   48.593573] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   48.600718] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   54.877567] net_ratelimit: 6 callbacks suppressed
>> [   54.882293] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>> [   61.413552] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>> length 1518
>
> The status error bits are in sky2.h
> 0x5f20010 is
>       05f2 frame length => 1522
>       0010 Too long err
>
> That means the packet was longer than the configured MTU.
> You are probably getting packets with VLAN tag but have not configured
> a VLAN.
>
>
>

Thanks for the information. I have increased the MTU value to 1550 
(workaround) and it works if sends traffic (with iperf) from my computer 
to the unit. But, if I send traffic outside the unit, I get a new error 
message and link goes down:

[ 4901.032989] sky2 0000:04:00.0 marvell: tx timeout
[ 4904.722670] sky2 0000:04:00.0 marvell: Link is up at 1000 Mbps, full 
duplex, flow control both

Rafa
