From: Willy Tarreau <willy@w.ods.org>
Subject: Re: HELP ipt_hook: happy cracking message
Date: Tue, 27 Apr 2004 20:57:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040427185729.GA29913@alpha.home.local>
References: <20040426151220.85059.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernerl mail <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org,
        netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Parag Nemade <cranium2003@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20040426151220.85059.qmail@web41403.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 26, 2004 at 08:12:20AM -0700, Parag Nemade wrote:
> hi,
>         i modified kernel so that it will create
> /proc/net/myproc file entry.
> the function of this entry is to crate a 16 byte char
> string from random no.s
> i used net_srandom and net_random and sys_time for
> that puspose. the problem is that i write program to
> generate string after 120 seconds but it is changing
> contents of myproc file every seconds. what can i do?

may be you're sleeping for 120 instead of 120*HZ, which
means you're really sleeping 1.2s on x86.

>  Also i am getting ipt_hook: happy cracking. message
> again and again why?

iptable_mangle.c comment reads 'root is playing with
raw sockets' above this message. It means that you're
sending too short IP packets (len < 20 bytes) or packets
with the IHL field < 5. It's just a harmless message.

Regards,
Willy
