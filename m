From: Patrick Schaaf <bof@bof.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 17:52:26 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729175226.B570@oknodo.bof.de>
References: <20020729131239.A5183@wotan.suse.de> <200207291525.g6TFPTTu011558@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <200207291525.g6TFPTTu011558@marajade.sandelman.ottawa.on.ca>; from mcr@sandelman.ottawa.on.ca on Mon, Jul 29, 2002 at 11:25:28AM -0400
List-Id: netdev.vger.kernel.org

> >>>>> "Andi" == Andi Kleen <ak@suse.de> writes:
>     Andi> (case in point: we have at least one report that routing
>     Andi> performance breaks down with ip_conntrack when memory size is
>     Andi> increased over 1GB on P3s. The hash table size depends on the
>     Andi> memory size. The problem does not occur on P4s. P4s have larger
>     Andi> TLBs than P3s.)
> 
>   That's a non-obvious result.
> 
>   I'll bet that most of the memory-size based hash tables in the kernel
> suffer from similar problems. A good topic for a paper, I'd say.

That's for sure - but I don't see the relevance of TLBs. The only place
where I expect any in-CPU caches to matter, is for synthetic test
cases where there's a very small number of conntracks (fitting into
CPU caches), and a huge load of packets (to look good in a benchmark).

Under real life operation, we either have very light loads - then conntrack
lookup does not matter at all - or we have high load, several 10000
packets per second. Then, things may get slow in conntrack when
you don't have enough hash buckets - two times the number of
concurrent connections is appropriate. Or, if that's not the
problem, you will already spread lookup so far across the hash
table, in a random fashion, that you'll incurr at least two TLB
faults plus several cache line loads for each packet. When that
point is reached, further increase in packet load should not
make things worse.

Andi, what report are you referring to? Any specifics I can read?

In case somebody isn't aware, we have been over the hash function
and hash bucket thing during the last month. See lots of mails in
the netfilter-devel archive.

I'm prepared to take on any presumed inefficiency in the current
conntracking code. I know some things that may be relevant that
I did not write about during the last weeks, but I have no real life
indication that they matter - I'd love to have the opportunity to
see such a situation. So if anybody got the time to work on such
a perceived performance problem, please come to the netfilter-devel
mailing lest, and let's talk specifics.

As it were, I published a small netfilter performance counter patch
over the weekend, which you can find in the archive at

http://lists.netfilter.org/pipermail/netfilter-devel/2002-July/008792.html

I hope to see some really worrying output from you :)

best regards
  Patrick
- 
