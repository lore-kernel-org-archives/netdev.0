From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] nfmark modify extension to classifiers
Date: 06 Oct 2003 18:39:47 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1065479986.1102.3.camel@jzny.localdomain>
References: <20031006002619.GC11250@rei.reeler.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Alexey <kuznet@ms2.inr.ac.ru>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20031006002619.GC11250@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi there,

This is a bad idea.
Please consider using the tc action extensions. 
I was going to write a generic metadata modifier action
(classid, tcindex, nfmark etc). Maybe you can beat me to it.

cheers,
jamal

On Sun, 2003-10-05 at 20:26, Thomas Graf wrote:
> Hello
> 
> The netfilter mark field is heavly used nowadays to communicate
> between tc, netfilter and ip rule.  Classifiers are not yet
> capable of modifying the nfmark field. However it would make
> sense, especially in ingress context.
> 
> Example:
> $TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32
> match ip protocol 6 0xff nfmark 0x10 flowid 10:12
>                          ^^^^^^^^^^^
> Would set nfmark=0x10 for all icmp packets.
> 
> Applications (examples):
>  - Differentiate source classifier if multiple classifiers
>    classify into a single class (match again with cls_fw.c).
>  - Mark packets in ingress and reuse nfmark in ip rules if
>    netfilter is too slow.
>  - Use rsvp(6)/route/tcindex capabilities in netfilter/ip rule.
> 
> Below is a patch to the u32 classifier adding this extension.
> It would be easy to do the same for other classifiers.
> (I also have a patch against tc if someone is interested.)
> 
> The ifdef mess cannot be avoided unless nfmark in skbuff is
> freed from its ifdefs.
> 
> Regards
