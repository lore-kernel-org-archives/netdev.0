From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Tue, 11 Nov 2003 15:13:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111151340.3d129bc7.davem@redhat.com>
References: <20031109122844.GA14241@wsx.ksp.sk>
	<20031110214603.0057e365.davem@redhat.com>
	<20031111222611.GA1239@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20031111222611.GA1239@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Nov 2003 23:26:11 +0100
Jan Oravec <jan.oravec@6com.sk> wrote:

> > The bus error you reported from running traceroute6 on the sparc64
> > system is not that useful, can you use gdb or some other tool to
> > figure out where inside of tcpdump6 the bus error is occuring?  Is is
> > happening in the tcpdump6 program itself?  It is due to a failed system
> > call?
> 
> I am running 64-bit-only userspace and there is no gdb/strace for sparc64
> yet :(.

Yes there is a gdb, here is a prebuilt 64-bit gdb for you.  It is even
statically linked so there are no shared library dependencies.  It can
debug 32-bit processes as well:

	ftp://pizda.ninka.net/pub/for_jakub/gdb64

Enjoy.

> But I think I have found the problem:
> 
> icmpv6_send() can get skb where skb->nh.raw < skb->data, thus computed plen
> (see icmp.c:382) is negative. When passed as unsigned int to __skb_pull, it
> underflows and is interpreted as 0x100000000-something_small. In __skb_pull
> we then increase skb->data by that number; because skb->data is 64-bit while
> plen is 32-bit, we get pointer which is 0x100000000 higher than needed. On
> 32-bit platform that does not cause any troubles because it overflows again.
> 
> I do not know whether icmpv6_send() was meant to receive skb with ->data
> pulled no more than nh.raw; in that case I suggest the following patch
> (against test9-bk16):

Great analysis, thanks a lot.

I will look at your patch proposals.
