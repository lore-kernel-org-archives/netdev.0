From: jamal <hadi@cyberus.ca>
Subject: Re: tcp flows hash function
Date: Wed, 4 Dec 2002 08:17:46 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0212040812180.2731-100000@shell.cyberus.ca>
References: <200212040738.NAA02825@eis.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: SVR Anand <anand@eis.iisc.ernet.in>
In-Reply-To: <200212040738.NAA02825@eis.iisc.ernet.in>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Anand,
why dont you give a shot at the comparisons and post your results.
You have already extracted the hashing function; so write a small program
in user space that you feed headers from real world webservers for
example to tcp_hashfn(); see how well the hashing is distributed
amongst the hash buckets; this should give you the rough number of
lookups needed in the linux hash function. Then try some of the trie
schemes with the same data.
I'd be interested in your results.

cheers,
jamal

On Wed, 4 Dec 2002, SVR Anand wrote:

> Hi,
>
> I am writing a program that requires maintanence of per-connection statistics
> of many tcp connections based on multi-field classification. The problem is
> that of fast search and update when there are 1000s of connections. Couple of
> questions.
>
> 1. In many places of network code, I am seeing hashing being used. Can I also
> use the same ?
>
> >From the recently published literature on packet classification, people are
> talking about some sort of trie variants. I would like to know if someone has
> done performance comparison of the algorithm used in Linux against other
> schemes.
>
>
> 2. While going through tcp_ipv4.c, I happened to see tcp_hashfn. What is the
> algorithm behind this ?
>
> static __inline__ int tcp_hashfn(__u32 laddr, __u16 lport,
>                                  __u32 faddr, __u16 fport)
> {
>         int h = ((laddr ^ lport) ^ (faddr ^ fport));
>         h ^= h>>16;
>         h ^= h>>8;
>         return h & (tcp_ehash_size - 1);
> }
>
>
> Any inputs from you will help me proceed further.
>
> Anand
>
>
