From: jamal <hadi@cyberus.ca>
Subject: Re: BUG: dst underflow (again)
Date: 04 Nov 2004 09:15:17 -0500
Message-ID: <1099577717.1039.155.camel@jzny.localdomain>
References: <4178AB0D.6060107@pobox.com>
	 <20041022.155159.98771450.yoshfuji@linux-ipv6.org>
	 <20041022075947.GA15795@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI "Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041022075947.GA15795@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff/Lennert 

Could you turn off netfilter and see if this continues to happen?

Know how to reproduce this? ;->

cheers,
jamal

On Fri, 2004-10-22 at 03:59, Lennert Buytenhek wrote:
> On Fri, Oct 22, 2004 at 03:51:59PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> > > As requested, I updated my kernel to see if the "BUG: dst underflow..." 
> > > messages disappeared.  Alas, they didn't.  dmesg and .config from 
> > > 2.6.9-final attached.
> > 
> > Okay, thanks, but hmm...
> > (We haven't met this issue... I really want to know tow to reproduce...)
> 
> FWIW, I'm seeing loads of these on the kernel that comes with Fedora
> Core 2, also in the ipv6.ko module.  I have 6to4 enabled, if that matters
> anything.
> 
> % dmesg | grep BUG | sort | uniq
> BUG: dst underflow -1: 3bcf9a80 at 42350024
> BUG: dst underflow 0: 3bcf9a80 at 423486d2
> BUG: dst underflow 0: 3bcf9a80 at 4235823d
> % cat /sys/module/ipv6/sections/.text
> 0x42345000
> 
> 0x42350024 - 0x42345000 = 0xb024, corresponds to:
> 	0000affa <ip6_dst_check>
> 
> 0x423486d2 - 0x42345000 = 0x36d2, corresponds to:
> 	0000339d <ip6_push_pending_frames>
> 
> 0x4235823d - 0x42345000 = 0x1323d, corresponds to:
> 	00012c0d <udpv6_sendmsg>	(god, that's one big function btw)
> 
> 
> --L
> 
> 
