From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 14:14:02 +0900
Message-ID: <20120423051359.GE11672@verge.net.au>
References: <61c89e02-c916-421e-b469-62b307853b1b@tahiti.vyatta.com>
	<1335110082.2132.22.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, eric dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1335110082.2132.22.camel@mojatatu>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 22, 2012 at 11:54:42AM -0400, Jamal Hadi Salim wrote:
> On Sun, 2012-04-22 at 08:22 -0700, Stephen Hemminger wrote:
> 
> > STT isn't really doing TCP, it just lying and pretending to be
> > TCP to allow TSO to work! There is no packet ordering, sequence
> > numbers or any real transport layer. 

Yes, that is my understanding. Originally I envisaged that an STT
implementation would rely more heavily on the TCP stack. However, as
STT doesn't rely on any of the features of TCP other than its header
this was not the case and (almost) bypassing the TCP stack seems
to be sufficient.

I believe the motivation for reusing TCP is, as Stephen suggests,
to allow some hardware acceleration to occur.

> True. It is a nice engineering hack but even as a protocol enhancement
> questionable at best.
> 
> > Therefore Simon's
> > proposed hook is the only way to support it. But exposing that
> > hook does allow for other misuse.
> 
> If you object to this, then you gotta object to the UDP equivalent 
> which has been around for sometime now for legitimate reasons

That is basically my reasoning too.

> and could be used by STT (I think the claim was no hardware
> does USO);->

I was not involved in the design of STT so I can't comment on that
although I do suspect you are correct.
