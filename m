From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: ip_conntrack: Make "hashsize" conntrack parameter writable
Date: Wed, 23 Nov 2005 15:08:28 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0511231456360.32233@ask.diku.dk>
References: <1132670984.17794.78.camel@localhost.localdomain>
 <1132707085.7720.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Harald Welte <laforge@netfilter.org>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org,
        Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <1132707085.7720.2.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 23 Nov 2005, Rusty Russell wrote:

> On Tue, 2005-11-22 at 15:49 +0100, Jesper Dangaard Brouer wrote:
>> Hi Rusty (and Harald)
>>
>> We met at the Netfilter Workshop 2005, where I complained that the
>> conntrack hashsize were statically set at module load time.
>>
>> Thank you making a kernel patch, which changes this...
>> BUT I cannot make it work! :-(
>>
>> http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=eed75f191d8318a2b144da8aae9774e1cfcae492
>>
>> Am I missing some part of the patch?
>>
>> I cannot find the link to the /proc file system. Should there not be
>> any changes to ip_conntrack_standalone.c ??
>
> /sys/module/ip_conntrack/parameters/hashsize
>
> Cheers!
> Rusty.

Aha I see, the sysfs filesystem.

I was confused, because the hashsize is already exported as 
/proc/sys/net/ipv4/netfilter/ip_conntrack_buckets.

It is a bit confusing, that the Netfilter team are changing away from the 
/proc filesystem, but I don't care, it seems that the sysfs filesystem is 
a more powerful choice.

The permissions on "/sys/module/ip_conntrack/parameters/hashsize" is set 
to 600, where the /proc/../ip_conntrack_buckets is readable to all (444). 
I think we should change the /sys/../hashsize parameter to 644, as it does 
not make sense as it is readable through /proc.

Hilsen
   Jesper Dangaard Brouer

ps. Cc'ing -> lets keep google updated ;-)
--
-------------------------------------------------------------------
Cand. scient datalog
Dept. of Computer Science, University of Copenhagen
-------------------------------------------------------------------
