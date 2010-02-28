From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: Adding inode field to /proc/net/netlink
Date: Sun, 28 Feb 2010 21:44:29 +0900 (JST)
Message-ID: <20100228.214429.962992518070045288.yamato@redhat.com>
References: <20100228.010057.229746532.davem@davemloft.net>
	<20100228.185045.366957605052790072.yamato@redhat.com>
	<1267350246.9082.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18796 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965834Ab0B1MQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 07:16:55 -0500
In-Reply-To: <1267350246.9082.69.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I understood but it has been already breaking:
>> 
>>     [yamato@xxx /proc/net]$ uname -a; cat /proc/net/netlink 
>>     Linux xxx.redhat.com 2.6.29.6-217.2.16.fc11.x86_64 #1 SMP Mon Aug 24 17:17:40 EDT 2009 x86_64 x86_64 x86_64 GNU/Linux
>>     sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks
>>     ffff8801bbde0400 0   2758   00000111 0        0        (null) 2
>>     ...
>> 
>>     [yamato@yyy /proc/net]$ uname -a; cat /proc/net/netlink 
>>     Linux yyy.redhat.com 2.6.30.10-105.2.23.fc11.x86_64 #1 SMP Thu Feb 11 07:06:34 UTC 2010 x86_64 x86_64 x86_64 GNU/Linux
>>     sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops
>>     ffff8800d83f5800 0   1783   00000001 0        0        (null) 2        0       
>> 
>> Drops field may be added between 2.6.29 and 2.6.30.
>> Adding one more field is really problem?
>> In other word, why "Drops" field was acceptable?
>> 
>> lsof uses following technique. It parses the header raw
>> (here "    sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops")
>> and picks values from columns only if the columns exits in the header raw.
>> e.g. If "Inode" exists in the header, lsof tries to use Inode value.
>> With the technique just adding(not deleting or swapping) a new column is not a big problem.
>> 
>> Masatake YAMATO
>> 
> 
> Indeed :)
> 
> I am a big fan of Vic Abell lsof tool that I used before Linux was even
> born :)

Thank you for supporting my patch.
I've already written a patch for lsof to use /proc/net/netlink. I'll submit it to him later.

I have not inspected well yet but there may be some protocols that /proc/net don't have
Inode field.
    
    # lsof | grep identi
    rpcbind   1555       rpc    4u     sock                0,5      0t0      13303 can't identify protocol
    dbus-daem 1570      dbus    7u     sock                0,5      0t0      13326 can't identify protocol
    cupsd     1590      root    3u     sock                0,5      0t0      13401 can't identify protocol
    bluetooth 1864      root    5u     sock                0,5      0t0      14749 can't identify protocol
    bluetooth 1864      root    8u     sock                0,5      0t0      14832 can't identify protocol
    bluetooth 1864      root    9u     sock                0,5      0t0      14846 can't identify protocol
    bluetooth 1864      root   10u     sock                0,5      0t0      14888 can't identify protocol
    bluetooth 1864      root   13u     sock                0,5      0t0      14947 can't identify protocol
    libvirtd  1972      root    7u     sock                0,5      0t0      15341 can't identify protocol

lsof deals following protocols:
    ax25
    ipx
    packet
    raw
    sockstat
    tcp
    udp
    udplite
    raw6
    sockstat6
    tcp6
    udp6
    udp6lite
    unix
    netlink

Masatake YAMATO
