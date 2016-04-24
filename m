From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Sun, 24 Apr 2016 11:38:52 +0200
Message-ID: <20160424113852.72d73735@griffin>
References: <cover.1461346798.git.jbenc@redhat.com>
	<017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
	<20160423014938.GD32327@pox.localdomain>
	<20160423050912.GA4520@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462AbcDXJi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 05:38:56 -0400
In-Reply-To: <20160423050912.GA4520@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Apr 2016 15:09:16 +1000, Simon Horman wrote:
> On Sat, Apr 23, 2016 at 03:49:38AM +0200, Thomas Graf wrote:
> > I may be missing some context. Is anyone using this already or is this
> > preparing the stage for another user? It's not clear to me from the
> > commit message.
> 
> Hi Thomas,
> 
> I'm not sure what use Jiri may have in mind but I plan to use
> this to allow OvS to support packets without an Ethernet header to
> be received from and sent to a GRE tunnel.
> 
> I am reasonably sure there are no existing users.

Yes, that's the main use case as far as I can see. Sorry for not being
clear.

The intention is to support tunnels that can have mixed L2+L3 traffic
over a single lwtunnel interface. VXLAN-GPE already does this, this
patch makes GRE behave identically, while preserving all current GRE
users.

The reason I sent this for net and not net-next is that I wanted to
prevent the situation when we have a kernel released that supports
ipgre lwtunnels but incompletely - i.e., ETH_P_TEB frames are
discarded. But thinking about it more, it's probably non-issue. I'll
retarget this patch for net-next and resend the first two for net.

Thanks,

 Jiri
