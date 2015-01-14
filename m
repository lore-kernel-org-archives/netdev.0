From: Florian Westphal <fw@strlen.de>
Subject: Re: 3.19-rc4:  BUG: unable to handle kernel paging request at
 ffff880055f15000 ovs_packet_cmd_execute+0x1f/0x229
Date: Wed, 14 Jan 2015 14:03:51 +0100
Message-ID: <20150114130351.GB13716@breakpoint.cc>
References: <1645184106.20150114131420@eikelenboom.it>
 <20150114130005.GA564@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:58032 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751995AbbANND7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 08:03:59 -0500
Content-Disposition: inline
In-Reply-To: <20150114130005.GA564@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> wrote:
> Copying ovs-dev mailing list and thus qutoing full message.
> 
> On 01/14/15 at 01:14pm, Sander Eikelenboom wrote:
> > Hi,
> > 
> > I was testing 3.19-rc4 with openvswitch and encountered the splat below.
> 
> What version of OVS are you using? Did this work properly with rc3 or
> an older kernel?

seems like it was introduced via 05da5898a96c
(openvswitch: Add support for OVS_FLOW_ATTR_PROBE).

It adds test for OVS_FLOW_ATTR_PROBE to ovs_packet_cmd_execute() but
this function seems to only expect OVS_PACKET_ATTR_* (so we get
out-of-bounds access)?
