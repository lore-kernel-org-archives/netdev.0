From: <Parav.Pandit@Emulex.Com>
Subject: RE: [PATCH] net: added support for 40GbE link.
Date: Tue, 19 Jun 2012 07:33:12 +0000
Message-ID: <5D6C0ABE6A236946864C45679362BBE20AC52269@CMEXMB1.ad.emulex.com>
References: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
	<1340039376.2913.13.camel@bwh-desktop.uk.solarflarecom.com>
 <20120619.002905.922583388766089167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:32806 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751878Ab2FSHdf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 03:33:35 -0400
In-Reply-To: <20120619.002905.922583388766089167.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, June 19, 2012 12:59 PM
> To: bhutchings@solarflare.com
> Cc: Pandit, Parav; netdev@vger.kernel.org
> Subject: Re: [PATCH] net: added support for 40GbE link.
> 
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 18 Jun 2012 18:09:36 +0100
> 
> > On Mon, 2012-06-18 at 18:14 +0530, Parav Pandit wrote:
> ...
> >> -/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
> >> +/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE, 40GbE. */
> >
> > I don't think there's any need to name all possible link speeds, and
> > it just encourages the bad practice of ethtool API users checking for
> > specific values.  You may notice there is no SPEED_20000.
> 
> Agreed.

Should eventually all net driver should remove using SPEED_xxxxxx and start using hard coded value of 10, 100, 1000, 20000?

> 
> >> @@ -542,13 +542,11 @@ static int prb_calc_retire_blk_tmo(struct
> >> packet_sock *po,
>  ...
> > This function should be fixed properly.  Firstly, it must use
> > ethtool_cmd_speed() rather than directly accessing ecmd.speed.
> > Secondly, it should allow any speed value rather than checking for
> > specific values.  Then there will be no need to make further changes
> > for 100G or any other new speed.
> 
> Agreed.

That means ethtool_cmd_speed() should not be called in this function?

If I understand correctly, it should return the value of 8ms (for 10Mb,s 100Mbps, 2.5 Gbps, 20Gbps) as today and remaining it should return calculated value?
Or
Function needs a fix for all these speeds (10Mbps, 100Mbs, 20Gbps too)?
