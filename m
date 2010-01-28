From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Thu, 28 Jan 2010 03:07:11 -0500
Message-ID: <1264666031.2793.117.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
	 <1264663210.2793.110.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264663210.2793.110.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-01-28 at 02:20 -0500, Jon Masters wrote:
> On Thu, 2010-01-28 at 00:46 -0500, Jon Masters wrote:
> 
> > A number of people seem to have reported this crash in various forms,
> > but I have yet to see a solution, and can reproduce on 2.6.33-rc5 this
> > evening so I know it's still present in the latest upstream kernels too.
> > Userspace is Fedora 12, and this happens on both all recent F12 kernels
> > (sporadic in 2.6.31 until recently, solidly reproducible on 2.6.32) and
> > upstream 2.6.32, and 2.6.33-rc5 also - hard to find a "known good".
> > 
> > The problem happens when using netfilter with KVM (problem does not
> > occur without the firewall loaded, for example) and will occur within a
> > few minutes of attempting to start or stop a guest that is connecting to
> > the network - the easiest way to reproduce so far is simply to start up
> > a bunch of Fedora guests and have them do a "yum update" cycle.
> > 
> > All of the crashes appear similar to the following (2.6.33-rc5):
> 
> Rebuilt the kernel with all debug options turned on, got some lockdep
> warnings (haven't looked further yet). Here's the output (attached full
> boot log also):

> [  339.730086] RIP: 0010:[<ffffffff813e5f3e>]  [<ffffffff813e5f3e>]
> nf_ct_remove_expectations+0x49/0x5c

This appears to be in the hlist_for_each_entry_safe iteration within
nf_ct_remove_expectations, iterating over the list of nf_conn_help(ers)
returned by nfct_help. I don't know what that code does (I have an idea
but only at a high level at this stage), though I'm poking a little here
to see if I can understand enough of netfilter to be useful. Feel free
to give me some pointers to help you guys debug this faster.

Jon.


