From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Mon, 17 Sep 2012 14:15:07 -0700
Message-ID: <20120917141507.7528b3ee@nehalam.linuxnetplumber.net>
References: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
	<20120917091214.5cd9b0f5@nehalam.linuxnetplumber.net>
	<20120917204724.GA1749@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mlindner@marvell.com,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38188 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781Ab2IQVPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 17:15:37 -0400
In-Reply-To: <20120917204724.GA1749@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Sep 2012 22:47:24 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Mon, Sep 17, 2012 at 06:12:14PM CEST, shemminger@vyatta.com wrote:
> >On Mon, 17 Sep 2012 17:10:17 +0200
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >> In my case I have following problem. sky2_set_multicast() sets registers
> >> GM_MC_ADDR_H[1-4] correctly to:
> >> 0000 0800 0001 0410
> >> However, when adapter gets link and sky2_link_up() is called, the values
> >> are for some reason different:
> >> 0000 0800 0016 0410
> >
> >Rather than papering over the problem, it would be better to
> >trace back what is setting those registers and fix that code.
> 
> Yes, I did that. No code at sky2.[ch] is writing to this registers other
> than sky2_set_multicast() and sky2_gmac_reset() (I hooked on sky2_write*()).
> So I strongly believe this is a HW issue (maybe only issue of my revision
> "Yukon-2 EC chip revision 2")
> 
> >
> >> This in my case prevents iface to be able to receive packets with dst mac
> >> 01:80:C2:00:00:02 (LACPDU dst mac), which I set up previously by
> >> SIOCADDMULTI.
> >> 
> >> So remember computed rx_filter data and write it to GM_MC_ADDR_H[1-4] on
> >> link_up.
> >>
> >
> >Please do some more root cause analysis. Just save/restoring the
> >registers is just a temporary workaround.

Are you sure it isn't IPv6 or something else setting additional mulitcast
addresses. You may need to instrument the set_multicast call.
