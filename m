From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [tcpdump-workers] Modular arithmetic
Date: Fri, 7 Sep 2012 20:03:11 -0700
Message-ID: <20120908030311.GM17289@tassilo.jf.intel.com>
References: <20120905213941.03c85968@arrowsmith>
 <C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
 <20120906073615.693d14e0@arrowsmith>
 <46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
 <20120907074910.2df46817@arrowsmith>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Schulist <jschlst@samba.org>, netdev@vger.kernel.org
To: George Bakos <gbakos@alpinista.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4158 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab2IHDDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 23:03:21 -0400
Content-Disposition: inline
In-Reply-To: <20120907074910.2df46817@arrowsmith>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 07, 2012 at 07:49:10AM +0000, George Bakos wrote:
> Gents,
> Any fundamental reason why the following (, etc.) shouldn't be
> included in net/core/filter.c?
> 
>                 case BPF_S_ALU_MOD_X:
>                         if (X == 0)
>                                 return 0;
>                         A %= X;
>                         continue;

Copying netdev.

In principle no reason against it, but you may need to update
the various BPF JITs too that Linux now has too.

-Andi

> 
> Cheers,
> g
> 
> On Thu, 6 Sep 2012 01:02:32 -0700
> Guy Harris <guy@alum.mit.edu> wrote:
> 
> > 
> > On Sep 6, 2012, at 12:36 AM, George Bakos wrote:
> > 
> > > $  tcpdump -nvr /tmp/DG2-test2 '(ip[2:2] - 20) % 5 != 0 && ip[6] &
> > > 0x20 = 0x20' 
> > > 
> > > reading from file /tmp/DG2-test2, link-type EN10MB (Ethernet)
> > > 19:01:51.270202 IP (tos 0x0, ttl 64, id 1, offset 40, flags [+],
> > > proto ICMP (1), length 61) 192.168.11.5 > 192.168.11.46: ip-proto-1
> > > 
> > > (000) ldh      [12]
> > > (001) jeq      #0x800           jt 2	jf 10
> > > (002) ldh      [16]
> > > (003) sub      #20
> > > (004) mod      #5
> > > (005) jeq      #0x0             jt 10	jf 6
> > 
> > OK, so you presumably added a BPF_MOD instruction to the BPF interpreter as part of your changes, right?  There's none in libpcap's bpf_filter.c nor in a fairly recent FreeBSD kernel's bpf_filter.c nor in Linux 3.0.4's net/core/filter.c, so that code won't work with at least those interpreters.
> > 
> > _______________________________________________
> > tcpdump-workers mailing list
> > tcpdump-workers@lists.tcpdump.org
> > https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
> 
> 
> -- 

-- 
ak@linux.intel.com -- Speaking for myself only
