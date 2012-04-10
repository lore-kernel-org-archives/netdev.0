From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute] tc pedit action: fix parsing offset options.
Date: Tue, 10 Apr 2012 09:08:44 -0700
Message-ID: <20120410090844.798023c3@nehalam.linuxnetplumber.net>
References: <CAEzD07+xdGxMh9-RHvF0RJZsCvj0Dj=VEY=0csPrSbTED4Hb6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44923 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246Ab2DJQIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 12:08:47 -0400
In-Reply-To: <CAEzD07+xdGxMh9-RHvF0RJZsCvj0Dj=VEY=0csPrSbTED4Hb6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Feb 2012 19:34:28 +0300
"Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com> wrote:

> This patch fix parsing offset option with "at" parameter.
> Tc returns error If keywords "offmask" and "shift" are presented.
> 
> Example of wrong parsing:
> 
> ~$ tc f add dev eth0 parent 1: protocol ip pref 10 \
> u32 match u32 0 0 \
> action pedit help
> Usage: ... pedit munge <MUNGE>
> Where: MUNGE := <RAW>|<LAYERED>
>         <RAW>:= <OFFSETC>[ATC]<CMD>
>                 OFFSETC:= offset <offval> <u8|u16|u32>
>                 ATC:= at <atval> offmask <maskval> shift <shiftval>
>                 NOTE: offval is byte offset, must be multiple of 4
>                 NOTE: maskval is a 32 bit hex number
>                 NOTE: shiftval is a is a shift value
>                 CMD:= clear | invert | set <setval>| retain
>         <LAYERED>:= ip <ipdata> | ip6 <ip6data>
>                 | udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>
> For Example usage look at the examples directory
> 
> #try to add filter with pedit action using "at" option
> ~$ tc f add dev eth0 parent 1: pref 10 protocol all handle ::10 \
> u32 match ip protocol 6 0xff \
> match ip src 10.10.20.119/32 \
> match ip dst 10.10.20.254/32 \
> action pedit munge offset 2 u16 at 0 offmask 0f0000000 shift 22 set 11500
> Illegal pedit construct (2)
> ...
> bad action parsing
> parse_action: bad value (19:pedit)!
> Illegal "action"
> 
> ~$ tc f add dev eth0 parent 1: pref 10 protocol all handle ::10 \
> u32 match ip protocol 6 0xff \
> match ip src 10.10.20.119/32 \
> match ip dst 10.10.20.254/32 \
> action pedit munge offset 2 u16 at 0 0f0000000 22 set 11500
> parse_cmd argc 8 set offset 2 length 2
> pack_key16: Final val ec2c0000 mask 0000ffff
> parse_cmd done argc 6 pipe offset 0 length 2
> 

Won't this break existing scripts because you changed the offset mask
from being a value to requiring a "offmask"?
