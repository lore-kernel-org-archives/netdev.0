From: Rayagond K <rayagond@vayavyalabs.com>
Subject: Re: how to test multipe unicast MAC address
Date: Mon, 8 Apr 2013 23:43:10 +0530
Message-ID: <CAJ3bTp4HnmZ9pvzEOUg5VAKiLYGxS+f6eqtb5HdXkmuUYdyZUw@mail.gmail.com>
References: <CAJ3bTp6xYkKwXNm_YZ9DTy9G8wdKqKEBQOVRjaGkmMURG2MaEA@mail.gmail.com>
	<1365430604.3887.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:35660 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934959Ab3DHSNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 14:13:12 -0400
Received: by mail-we0-f179.google.com with SMTP id p43so4827354wea.10
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 11:13:11 -0700 (PDT)
In-Reply-To: <1365430604.3887.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 8, 2013 at 7:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-04-08 at 12:38 +0530, Rayagond K wrote:
>> Hi All,
>>
>> How to assign multiple unicast MAC address to single interface ?
>> How to test multiple unicast MAC address filtering ?
>>
>> Thanks in advance.
>>
>
> Standard way would be to use macvlan
>
> ip link add link eth0 name foo02 addr 44:44:44:44:00:02 type macvlan
> ip link add link eth0 name foo03 addr 44:44:44:44:00:03 type macvlan

I tried this, but this won't update the uc address and in netdev
struct  and won't call .ndo_set_multicast_list.

I am planning to use vlan through vconfig as below,

#vconfig add eth0 100
#ifconfig eth0.100 10.144.134.1 netmask 255.255.255.0 up
#ifconfig eth0.100 hw ether 00:55:22:44:f7:80

This will update uc in netdev and calls .ndo_set_multicast_list.

>
>
