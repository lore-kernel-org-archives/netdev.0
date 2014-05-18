From: Guy Harris <guy@alum.mit.edu>
Subject: Re: Modular arithmetic
Date: Sun, 18 May 2014 11:26:46 -0700
Message-ID: <A58D120A-C942-4E06-8D41-CB7607B02AE0@alum.mit.edu>
References: <20120905213941.03c85968@arrowsmith>
 <C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
 <20120906073615.693d14e0@arrowsmith>
 <46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
 <20120907074910.2df46817@arrowsmith>
 <20120908030311.GM17289@tassilo.jf.intel.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
 <1347269124.1234.1326.camel@edumazet-glaptop>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6FE5@saturn3.aculab.com>
 <2B555EBC-A130-476B-9E29-DB75E668904E@alum.mit.edu>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>, Eric Dumazet <eric.dumazet@gmail.com>,
 netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org,
 Jay Schulist <jschlst@samba.org>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <2B555EBC-A130-476B-9E29-DB75E668904E@alum.mit.edu>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
 <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers/>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
 <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
Sender: "tcpdump-workers" <tcpdump-workers-bounces@lists.tcpdump.org>
List-Id: netdev.vger.kernel.org


On Sep 10, 2012, at 10:50 AM, Guy Harris <guy@alum.mit.edu> wrote:

> 
> On Sep 10, 2012, at 3:41 AM, "David Laight" <David.Laight@ACULAB.COM> wrote:
> 
>>>> What about the other OS - eg all the BSDs?
>>>> I had a vague idea that BPF was supposed to be reasonable portable.
>>> 
>>> Yes, does it mean BPF is frozen ?
>>> 
>>> Or is BSD so hard to update these days ?
>> 
>> Not really - but it some other places that need updating in order
>> to make this useful for cross-platform tools (like tcpdump).
>> 
>> The 'real fun (tm)' happens when NetBSD tries to run Linux binaries
>> that include the Linux libpcap.
> 
> Additional fun happens when a Linux system with a kernel that doesn't have the mod instruction tries to run Linux binaries that include a Linux libpcap that generates code using the mod instruction; this is not a BSD-vs.-Linux issue, it's a "kernel that lacks the mod instruction vs. libpcap that generates code that includes the mod instruction" issue.
> 
> BSD/OS X, Linux, Solaris, and the WinPcap driver need, if they adopt new BPF instructions, to have a mechanism by which libpcap (or anything else using BPF filtering) can inquire about the capabilities of the OS BPF interpreter; libpcap would use that to determine what code to generate if generating code for the in-kernel BPF interpreter.

In this particular case, there's no choice about what to generate - either you have mod and XOR instructions or you don't.

Furthermore, if the kernel rejects a particular BPF program, libpcap just falls back on filtering in userland, so we can support % and ^ operators in libpcap on all platforms, albeit with a performance hit on Linux prior to 3.7 and, currently, on other platforms.  I don't think there's anything inherently troublesome about BPF_MOD and BPF_XOR, so I'll file bugs against the various BSDs and OS X suggesting that they be added.

So I've checked in a change to libpcap to implement BPF_MOD and BPF_XOR and to add % and ^ operators (yes, the same zero-divide checks in bpf_validate() done for BPF_DIV are done for BPF_MOD, and the optimizer was updated to handle BPF_MOD like BPF_DIV and to handle BPF_XOR like BPF_OR).  The pcap-filter man page documents it, but warns that filters using them might be run in userland on pre-3.7 Linux and non-Linux platforms.
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
