From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6: Blackhole route support partial ?
Date: Mon, 11 Nov 2013 21:39:54 +0100
Message-ID: <20131111203954.GB3043@order.stressinduktion.org>
References: <CAP8BHkGZ5EFxW4BNervKrOiEaQTNdSh9s2YOrFoexzQCOR=AqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kamala R <kamala@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36201 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab3KKUj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 15:39:56 -0500
Content-Disposition: inline
In-Reply-To: <CAP8BHkGZ5EFxW4BNervKrOiEaQTNdSh9s2YOrFoexzQCOR=AqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Mon, Nov 11, 2013 at 07:25:14PM +0530, Kamala R wrote:
> On adding IPv6 blackhole routes, ICMP unreachable messages are being
> sent back to source. According to the definition, packets destined to
> a blackhole address must be dropped silently.

Yes, this is a bug.

> I applied the patch submitted to the 3.7 kernel that indicates that it
> supports blackhole and prohibit routes correctly. However, the patch
> only sets the error code and route type correctly, so the show command
> displays the appropriate output.
> 
> 
> It seems to me that the input and output function pointers of the dst
> variable, which determine packet processing, need to be set to
> dst_discard. This would enable correct behaviour for blackhole routes.
> Am I on the right path here ?

I think you are. ip6_pkt_discard is not the correct input/output
function for blackhole routes. In ip6_route_add simply set up the
function pointers in the switch instead to just initializing them to
ip6_pkt_discard. dst_discard is fine. Looks like prohibit rules are not
handled correctly either. They should go to ip6_pkt_prohibit. (Just look at
how the templates are initialized.)

Could you cook a patch?

Thanks,

  Hannes
