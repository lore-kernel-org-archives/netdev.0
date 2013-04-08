From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: how to test multipe unicast MAC address
Date: Mon, 08 Apr 2013 13:28:05 -0700
Message-ID: <51632855.5090806@gmail.com>
References: <CAJ3bTp6xYkKwXNm_YZ9DTy9G8wdKqKEBQOVRjaGkmMURG2MaEA@mail.gmail.com> <1365430604.3887.8.camel@edumazet-glaptop> <CAJ3bTp4HnmZ9pvzEOUg5VAKiLYGxS+f6eqtb5HdXkmuUYdyZUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:58866 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935830Ab3DHU23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:28:29 -0400
Received: by mail-oa0-f53.google.com with SMTP id m17so6710622oag.12
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 13:28:29 -0700 (PDT)
In-Reply-To: <CAJ3bTp4HnmZ9pvzEOUg5VAKiLYGxS+f6eqtb5HdXkmuUYdyZUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2013 11:13 AM, Rayagond K wrote:
> On Mon, Apr 8, 2013 at 7:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Mon, 2013-04-08 at 12:38 +0530, Rayagond K wrote:
>>> Hi All,
>>>
>>> How to assign multiple unicast MAC address to single interface ?
>>> How to test multiple unicast MAC address filtering ?
>>>
>>> Thanks in advance.
>>>
>>
>> Standard way would be to use macvlan
>>
>> ip link add link eth0 name foo02 addr 44:44:44:44:00:02 type macvlan
>> ip link add link eth0 name foo03 addr 44:44:44:44:00:03 type macvlan
>
> I tried this, but this won't update the uc address and in netdev
> struct  and won't call .ndo_set_multicast_list.
>

This should work macvlan calls uc_sync and mc_sync on the lowerdev. It
is working on the tip at least,

# bridge fdb show dev p3p2
01:00:5e:00:00:01 self permanent
33:33:00:00:00:01 self permanent
33:33:ff:69:9f:09 self permanent
# ip link add link p3p2 address 00:11:22:33:44:55 type macvlan
# ip link set dev macvlan0 up
# bridge fdb show dev p3p2
00:11:22:33:44:55 self permanent
01:00:5e:00:00:01 self permanent
33:33:00:00:00:01 self permanent
33:33:ff:69:9f:09 self permanent
33:33:ff:33:44:55 self permanent


> I am planning to use vlan through vconfig as below,
>
> #vconfig add eth0 100
> #ifconfig eth0.100 10.144.134.1 netmask 255.255.255.0 up
> #ifconfig eth0.100 hw ether 00:55:22:44:f7:80
>
> This will update uc in netdev and calls .ndo_set_multicast_list.
>



-- 
John Fastabend         Intel Corporation
