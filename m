From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 12/16] selinux: Set socket NetLabel based on connection endpoint
Date: Wed, 1 Oct 2008 11:09:25 -0400
Message-ID: <200810011109.25573.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <alpine.LRH.1.10.0810011958380.6732@tundra.namei.org> <7DC4373B-194C-43FC-B4FB-B867999CAE76@nall.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Joe Nall <joe@nall.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <7DC4373B-194C-43FC-B4FB-B867999CAE76@nall.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 October 2008 10:51:31 am Joe Nall wrote:
> On Oct 1, 2008, at 5:00 AM, James Morris wrote:
> > On Tue, 16 Sep 2008, Paul Moore wrote:
> >> /**
> >> + * cipso_v4_sock_delattr - Delete the CIPSO option from a socket
> >> + * @sk: the socket
> >> + *
> >> + * Description:
> >> + * Removes the CIPSO option from a socket, if present.
> >> + *
> >> + */
> >> +void cipso_v4_sock_delattr(struct sock *sk)
> >
> > Reviewed-by: James Morris <jmorris@namei.org>
> >
> >
> > Btw, what kind of testing has this patch had?
>
> Paul generated a patch for us against 2.6.26-5 that we have on about
> 20 developer and test boxes with good results in MLS enforcing. We
> are adding IPSec between machines and static fallback labels  to the
> test mix and will report any issues. We have a couple of 8 core
> machines I'll stress test on to look for SMP issues.

Thanks Joe, however, I think James was talking specifically about the 
this patch, not the entire aggregate patchset, and the 
cipso_v4_sock_delattr() function in particular as it is not likely to 
be called often in normal use.

To answer that question, I was going to write a small little test 
program that would connect/disconnect UDP sockets and do writes in 
various states to ensure the wire traffic was labeled (or not) 
correctly.  However, I had a bit of luck and Casey ended up using this 
function in Smack[1] in a manner that saw it in a relatively common 
code path so it got a decent test; in fact it was Casey who pointed out 
the bugs in the initial revision.

[1] The Smack bits are still a work in progress and not ready for 2.6.28 
so they have been left out of this patchset, expect something in the 
2.6.29 timeframe.

-- 
paul moore
linux @ hp
