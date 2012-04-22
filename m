From: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Sun, 22 Apr 2012 08:22:24 -0700 (PDT)
Message-ID: <61c89e02-c916-421e-b469-62b307853b1b@tahiti.vyatta.com>
References: <20120421.153743.699070106218049860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120421.153743.699070106218049860.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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


> From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> Date: Thu, 19 Apr 2012 13:53:35 +0900
> 
> > This hook is based on a hook of the same name provided by UDP.  It
> > provides
> > a way for to receive packets that have a TCP header and treat them
> > in some
> > alternate way.
> > 
> > It is intended to be used by an implementation of the STT tunneling
> > protocol within Open vSwtich's datapath. A prototype of such an
> > implementation has been made.
> > 
> > The STT draft is available at
> > http://tools.ietf.org/html/draft-davie-stt-01
> 
> I think that unlike UDP, you need to let the stack handle the TCP
> packet before taking it into your subsystem.  The reason is that
> otherwise you'll need to handle packet ordering, sequence number
> gaps,
> and proper TCP ACK'ing and timeout all inside of your module and
> that's simply unacceptable.

STT isn't really doing TCP, it just lying and pretending to be
TCP to allow TSO to work! There is no packet ordering, sequence
numbers or any real transport layer.  Therefore Simon's
proposed hook is the only way to support it. But exposing that
hook does allow for other misuse.
