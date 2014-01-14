From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] IPv6: add option to use anycast addresses as source addresses in icmp error messages
Date: Wed, 15 Jan 2014 00:38:55 +0100
Message-ID: <20140114233855.GB16276@order.stressinduktion.org>
References: <1389633764-5210-1-git-send-email-fx.lebail@yahoo.com> <20140114131344.GR6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, Bill Fink <billfink@mindspring.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37484 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbaANXi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:38:56 -0500
Content-Disposition: inline
In-Reply-To: <20140114131344.GR6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 02:13:44PM +0100, Hannes Frederic Sowa wrote:
> On Mon, Jan 13, 2014 at 06:22:44PM +0100, Francois-Xavier Le Bail wrote:
> > - Add "anycast_src_icmp_error" sysctl to control the use of anycast addresses
> >   as source addresses for ICMPv6 error messages. This sysctl is false by
> >   default to preserve existing behavior.
> > - Use it in icmp6_send().
> > 
> > Suggested-by: Bill Fink <billfink@mindspring.com>
> > Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> 
> Regarding the anycast patches, I contacted someone from IETF.
> 
> The number of sysctls needed to get introduced to have all the flexibility
> regarding source address selection and don't break backward compatibility
> concerns me a bit.
> 
> Especially on end hosts, where those switches will be important, I think we
> really have to think about sensible defaults without breaking current
> software.
> 
> I currently consider a per-address flag, if those anycast addresses
> should be available in source address selection (also with an enhancement to
> current IPV6_JOIN_ANYCAST logic).

Francois, we should really think about this. Also if we should just
make the pre-defined subnet address just a normal anycast address in the
long-term (which just happens to get automatically added to an interface
if forwarding is enabled) and bundle all the source address selection
logic on the per-address state.

If that would be the case, we could revert
509aba3b0d366b7f16a9a2eebac1156b25f5f622 ("IPv6: add the option to use
anycast addresses as source addresses in echo reply") and thus would
eliminate one sysctl.

It would be fine if we can make this decision before David merges with
Linus.  I guess we can still do this decision while in -rc phase. But
as soon as the knob is in a released version of linux we can never take
it back (I really don't like sysctls).

Greetings,

  Hannes
