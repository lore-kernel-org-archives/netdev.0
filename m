From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 12/14] mlx4: use netdev_rss_key_fill() helper
Date: Sat, 22 Nov 2014 15:58:10 -0800
Message-ID: <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
	 <1416692961.7215.31.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:39645 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaKVX6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 18:58:13 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so1478107igb.5
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 15:58:12 -0800 (PST)
In-Reply-To: <1416692961.7215.31.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-11-22 at 21:49 +0000, Ben Hutchings wrote:
> On Sun, 2014-11-16 at 06:23 -0800, Eric Dumazet wrote:
> > Use of well known RSS key increases attack surface.
> > Switch to a random one, using generic helper so that all
> > ports share a common key.
> > 
> > Also provide ethtool -x support to fetch RSS key
> [...]
> > @@ -1799,6 +1805,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
> >  	.get_rxnfc = mlx4_en_get_rxnfc,
> >  	.set_rxnfc = mlx4_en_set_rxnfc,
> >  	.get_rxfh_indir_size = mlx4_en_get_rxfh_indir_size,
> > +	.get_rxfh_key_size = mlx4_en_get_rxfh_key_size,
> >  	.get_rxfh = mlx4_en_get_rxfh,
> >  	.set_rxfh = mlx4_en_set_rxfh,
> [...]
> 
> A driver that implements get_rxfh_key_size() and set_rxfh() is assumed
> to support setting the RSS key (and only the key).  However,
> mlx4_en_set_rxfh() will currently crash if a new indirection table is
> not provided.

Hi Ben.

Is this a net-next only concern, or is it an existing problem in net
tree ?

Thanks !
