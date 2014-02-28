From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] bonding: send arp requests even if there's no
 route to them
Date: Fri, 28 Feb 2014 03:38:19 -0800
Message-ID: <1393587499.10280.10.camel@joe-AO722>
References: <1393585076-22786-1-git-send-email-vfalico@redhat.com>
	 <1393585971.10280.5.camel@joe-AO722> <20140228112840.GA11907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Fran=E7ois?= CACHEREUL <f.cachereul@alphalink.fr>,
	Zhenjie Chen <zhchen@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0180.hostedemail.com ([216.40.44.180]:57849 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751296AbaB1LiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 06:38:22 -0500
In-Reply-To: <20140228112840.GA11907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 12:28 +0100, Veaceslav Falico wrote:
> On Fri, Feb 28, 2014 at 03:12:51AM -0800, Joe Perches wrote:
> >On Fri, 2014-02-28 at 11:57 +0100, Veaceslav Falico wrote:
> ...snip...
> >> +			if (bond->params.arp_validate)
> >> +				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
> >> +					bond->dev->name, &targets[i]);
> >
> >Maybe
> >
> >			if (bond->params.arp_validate && net_ratelimit())
> 
> Hm, not that I'm against it - but bond_arp_send_all() is called every
> arp_interval - which is usually >50ms. Does it really make sense to put it
> here?

Dunno, but you're converting a generally not emitted pr_debug
(DEBUG isn't set, so it'd have to be enabled by dynamic_debug)
to something that'll always print out a line for each of up to
16 targets, so it seems it could be pretty noisy.
