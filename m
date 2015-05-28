From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 11:30:38 -0400 (EDT)
Message-ID: <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com> <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com> <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:52752 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234AbbE1Paj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 11:30:39 -0400
In-Reply-To: <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 28, 2015 at 11:14 AM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> On Thu, 2015-05-28 at 10:38 -0400, jsullivan@opensourcedevel.com wrote:
>
<snip>
> IFB has still a long way before being efficient.
>
> In the mean time, you could play with following patch, and
> setup /sys/class/net/eth0/gro_timeout to 20000
>
> This way, the GRO aggregation will work even at 1Gbps, and your IFB will
> get big GRO packets instead of single MSS segments.
>
> Both IFB but also IP/TCP stack will have less work to do,
> and receiver will send fewer ACK packets as well.
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> b/drivers/net/ethernet/intel/igb/igb_main.c
> index
> f287186192bb655ba2dc1a205fb251351d593e98..c37f6657c047d3eb9bd72b647572edd53b1881ac
> 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -151,7 +151,7 @@ static void igb_setup_dca(struct igb_adapter *);
> #endif /* CONFIG_IGB_DCA */
<snip>

Interesting but this is destined to become a critical production system for a
high profile, internationally recognized product so I am hesitant to patch.  I
doubt I can convince my company to do it but is improving IFB the sort of
development effort that could be sponsored and then executed in a moderately
short period of time? Thanks - John
