From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 03:36:58 -0400 (EDT)
Message-ID: <20120423.033658.1229108613501573952.davem@davemloft.net>
References: <61c89e02-c916-421e-b469-62b307853b1b@tahiti.vyatta.com>
	<1335110082.2132.22.camel@mojatatu>
	<20120423051359.GE11672@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120423051359.GE11672-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Date: Mon, 23 Apr 2012 14:14:02 +0900

> On Sun, Apr 22, 2012 at 11:54:42AM -0400, Jamal Hadi Salim wrote:
>> On Sun, 2012-04-22 at 08:22 -0700, Stephen Hemminger wrote:
>> 
>> > STT isn't really doing TCP, it just lying and pretending to be
>> > TCP to allow TSO to work! There is no packet ordering, sequence
>> > numbers or any real transport layer. 
> 
> Yes, that is my understanding. Originally I envisaged that an STT
> implementation would rely more heavily on the TCP stack. However, as
> STT doesn't rely on any of the features of TCP other than its header
> this was not the case and (almost) bypassing the TCP stack seems
> to be sufficient.
> 
> I believe the motivation for reusing TCP is, as Stephen suggests,
> to allow some hardware acceleration to occur.

Yes, this is what the IETF draft states.

But I wonder about your encap_rcv hook placement, nevermind
that your posted patch won't compile since tcp_sock lacks
an encap_tcv member and your patch didn't add one. :-)

You'll need to somehow create either a fully established or a
listening socket for that hook to work.

You'd need to perform a full handshake to get a socket into
established state, and it seems STT doesn't do a TCP handshake.

That leaves you with the listening socket option, and in that case I
want to know how you're going to send packets out of this STT tunnel?

In order to get the advertised benefits of this STT thing, you'll need
to go through the whole TCP data packet sending engine, in order to
get all the TSO/GSO stuff initialized properly on the SKB so the NIC
will do it's thing.

But you can't send data out of an un-established TCP socket.

At the very least, we'll need to see the rest of your full
implementation before we can say whether this encap_rcv hook is the
right way to do things.
