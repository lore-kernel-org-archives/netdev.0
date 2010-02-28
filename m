From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: Adding inode field to /proc/net/netlink
Date: Sun, 28 Feb 2010 18:50:45 +0900 (JST)
Message-ID: <20100228.185045.366957605052790072.yamato@redhat.com>
References: <20100228.144537.445518512048328806.yamato@redhat.com>
	<20100228.010057.229746532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031648Ab0B1JXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 04:23:15 -0500
In-Reply-To: <20100228.010057.229746532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Masatake YAMATO <yamato@redhat.com>
> Date: Sun, 28 Feb 2010 14:45:37 +0900 (JST)
> 
>> The Inode field in /proc/net/{tcp,udp,packet,raw,...} is useful to know the types of 
>> file descriptors associated to a process. Actually lsof utility uses the field.
>> Unfortunately, unlike /proc/net/{tcp,udp,packet,raw,...}, /proc/net/netlink doesn't have the field.
>> This patch adds the field to /proc/net/netlink.
>> 
>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> Unfortunately we cannot add new fields without breaking the parsing
> done by existing applications.

I understood but it has been already breaking:

    [yamato@xxx /proc/net]$ uname -a; cat /proc/net/netlink 
    Linux xxx.redhat.com 2.6.29.6-217.2.16.fc11.x86_64 #1 SMP Mon Aug 24 17:17:40 EDT 2009 x86_64 x86_64 x86_64 GNU/Linux
    sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks
    ffff8801bbde0400 0   2758   00000111 0        0        (null) 2
    ...

    [yamato@yyy /proc/net]$ uname -a; cat /proc/net/netlink 
    Linux yyy.redhat.com 2.6.30.10-105.2.23.fc11.x86_64 #1 SMP Thu Feb 11 07:06:34 UTC 2010 x86_64 x86_64 x86_64 GNU/Linux
    sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops
    ffff8800d83f5800 0   1783   00000001 0        0        (null) 2        0       

Drops field may be added between 2.6.29 and 2.6.30.
Adding one more field is really problem?
In other word, why "Drops" field was acceptable?

lsof uses following technique. It parses the header raw
(here "    sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops")
and picks values from columns only if the columns exits in the header raw.
e.g. If "Inode" exists in the header, lsof tries to use Inode value.
With the technique just adding(not deleting or swapping) a new column is not a big problem.

Masatake YAMATO

