From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Wed, 11 Mar 2009 16:12:08 +0100
Message-ID: <20090311151208.GF4738@xi.wantstofly.org>
References: <49AD1C81.1020106@mlbassoc.com> <1236083560.30736.114.camel@localhost.localdomain> <49AD2FE1.60305@mlbassoc.com> <49AD30F7.4080006@mlbassoc.com> <49ADA697.3050400@mlbassoc.com> <49B145FF.5060208@mlbassoc.com> <20090310102805.GO4738@xi.wantstofly.org> <49B64CF5.9090508@mlbassoc.com> <20090310133635.GS4738@xi.wantstofly.org> <49B6831A.4080506@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdb@comx.dk, Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:48303 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbZCKPML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 11:12:11 -0400
Content-Disposition: inline
In-Reply-To: <49B6831A.4080506@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 09:11:22AM -0600, Gary Thomas wrote:

> >> For my particular setup, there are two cases (on the same
> >> board):
> >>   Switch 1 - ports 1..8
> >>   Switch 2 - ports 9..16
> >>     Switch 3 - ports 17..24 (cascaded off of Switch 2)
> >> Thus, the only access to Switch 3 and its ports is indirect via
> >> Switch 2.
> >>
> >> Presumably, one could have a multiple cascade, so this structure
> >> should be considered from the start.
> > 
> > Switch 1 can correspond to its own DSA platform device as it is now.
> > 
> > And for switch 2/3 you'd then have something a la:
> > 
> > 
> > struct dsa_switch_data switches[] = {
> > 	{
> > 		.mii_bus = &blah,
> > 		.sw_addr = 2,
> > 		.port_names[0] = "p9",
> > 		.port_names[1] = "p10",
> > 		.port_names[2] = "p11",
> > 		.port_names[3] = "p12",
> > 		.port_names[4] = "p13",
> > 		.port_names[5] = "p14",
> > 		.port_names[6] = "p15",
> > 		.port_names[7] = "p16",
> > 		.port_names[9] = "dsa",
> > 		.port_names[10] = "cpu",
> > 	}, {
> > 		.mii_bus = &blah,
> > 		.sw_addr = 3,
> > 		.port_names[0] = "p17",
> > 		.port_names[1] = "p18",
> > 		.port_names[2] = "p19",
> > 		.port_names[3] = "p20",
> > 		.port_names[4] = "p21",
> > 		.port_names[5] = "p22",
> > 		.port_names[6] = "p23",
> > 		.port_names[7] = "p24",
> > 		.port_names[9] = "dsa",
> > 	},
> > };
> > 
> > struct dsa_platform_data switch23 = {
> > 	.netdev = &blah,
> > 	.nr_switches = 2,
> > 	.sw = switches,
> > 	.rtable = {
> > 		{ -1,  9 },
> > 		{  9, -1 },
> > 	},
> > };
> > 
> > Or something along those lines.
> > 
> > Thoughts?
> 
> The setup looks good.  Let me know when you have the rest of
> the patch ready to test (I'm all setup here)

OK, I hit a snag with my initial implementation (we can't put an array
of dsa_switch in dsa_switch_tree as dsa_switch has driver-private data
at the end, making it variable length), but I should hopefully have a
patch by day end.
