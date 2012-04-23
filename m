From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 12:19:34 -0700
Message-ID: <20120423121934.195e898c@nehalam.linuxnetplumber.net>
References: <20120423051359.GE11672@verge.net.au>
	<20120423.033658.1229108613501573952.davem@davemloft.net>
	<20120423083007.GB22556@verge.net.au>
	<20120423.151533.694306336485319759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120423.151533.694306336485319759.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Mon, 23 Apr 2012 15:15:33 -0400 (EDT)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> Date: Mon, 23 Apr 2012 17:30:08 +0900
> 
> > I'm pretty sure the patch I posted added encap_rcv to tcp_sock.
> > Am I missing the point?
> 
> It did, my eyes are failing me :-)
> 
> > Currently I am setting up a listening socket. The Open vSwtich tunneling
> > code transmits skbs and using either dev_queue_xmit() or ip_local_out().
> > I'm not sure that I have exercised the ip_local_out() case yet.
> 
> I don't see where on transmit you're going to realize the primary
> stated benefit of STT, that being TSO/GSO.
> 
> You'll probably want to gather as many packets as possible into a
> larger STT frame for this purpose.  And when switching between STT
> tunnels, leave the packet alone since a GRO STT frame on receive will
> transparently become a STT GSO frame on transmit.
> 

I think the point of the TSO hack is to get around the MTU problem when tunneling.
The added header of the tunnel eats into the the possible MTU. The use of TSO
in STT is designed to deal with the fact that hardware can't do IP fragmentation
of IP (or UDP).
