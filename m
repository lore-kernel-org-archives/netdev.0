From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSecv6/Neighbor discovery crash
Date: Fri, 22 Aug 2003 15:58:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030822155812.06ab718f.davem@redhat.com>
References: <200308222312.h7MNCAJl019005@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: latten@austin.ibm.com
In-Reply-To: <200308222312.h7MNCAJl019005@faith.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Aug 2003 18:12:10 -0500
latten@austin.ibm.com wrote:

> So I do not know where or what are some of
> the values ndisc_output() or ndisc_build_ll_addr() are using.
> Nothing gets written to my log file when I do the ping6.
 ...
> > > EIP is at ndisc_build_ll_hdr+0x17/0x1e0

Why not save yourself all that debugging effort and just
use gdb on the kernel image and:

(gdb) x/10i ndisc_build_ll_hdr+0x17

then match that assembler up with the output of:

bash$ make net/ipv6/ndisc.s

I'm flabbergasted that someone would resort to printk()'s
to figure out the precise location of this OOPS when the
OOPS says exactly the location :(
