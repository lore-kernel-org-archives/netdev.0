From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 10:35:30 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <1027964130.3d457ce2c40e9@imap.linux.ibm.com>
References: <20020729131239.A5183@wotan.suse.de> <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca> <20020729135615.A20412@wotan.suse.de> <1027957218.12610.71.camel@tux>  <20020729181501.C570@oknodo.bof.de> <1027962751.12630.92.camel@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Patrick Schaaf <bof@bof.de>, Andi Kleen <ak@suse.de>,
   jamal <hadi@cyberus.ca>, Rusty Russell <rusty@rustcorp.com.au>,
   Netfilter-devel <netfilter-devel@lists.netfilter.org>, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1027962751.12630.92.camel@tux>
List-Id: netdev.vger.kernel.org

Quoting Martin Josefsson <gandalf@wlug.westbo.se>:

> > I don't see RCU solving hash link list update problems. Care to
> > explain how that would work?
> 
> Have you seen the rtcache RCU patch? it almost halved the time
> spent doing the lookups because of no lock bouncing between cpu's.
> But RCU is best suited for things that can tolerate stale data
> on reads, something which we can not. I've spoken to Hana Linder 
> who is one of the RCU people and she said that the dcache RCU patch
> uses some techniques to solve this as the dcache can't tolerate 
> stale data either.

The other environment parameter that RCU does best in is that
read:write ratio is high, in order to swallow the overhead. 
I havent looked into netfilter code, dont have much experience
in that area to suggest what your normal traffic would consist 
of. However, I've seen some posts and data from Dipankar
and Hanna which suggest the tradeoff is at a lower ratio than
we were used to (I was in Sequent's ptx/TCP/IP team where we
used it heavily, but our machines were NUMA boxes with a staggering
10:1 penalty for going off quad, back in the olden days).

> I havn't investigated this yet but it got my attention.
> 
> But the fact is that not many routers are SMP machines.
> Maybe it could help some very busy SMP servers?

Hope so :)

thanks,
Nivedita
