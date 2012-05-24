From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH 04/21] vswitchd: Add iface_parse_tunnel
Date: Fri, 25 May 2012 08:59:09 +0900
Message-ID: <20120524235907.GA7090@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
 <1337850554-10339-5-git-send-email-horms@verge.net.au>
 <20120524164738.GE26173@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51989 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464Ab2EXX7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 19:59:12 -0400
Content-Disposition: inline
In-Reply-To: <20120524164738.GE26173@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 09:47:38AM -0700, Ben Pfaff wrote:
> The concept seems OK to me here.  I have only a few minor comments.
> 
> On Thu, May 24, 2012 at 06:08:57PM +0900, Simon Horman wrote:
> > +#define TNL_F_CSUM          (1 << 0) /* Checksum packets. */
> > +#define TNL_F_TOS_INHERIT	(1 << 1) /* Inherit ToS from inner packet. */
> > +#define TNL_F_TTL_INHERIT	(1 << 2) /* Inherit TTL from inner packet. */
> > +#define TNL_F_DF_INHERIT	(1 << 3) /* Inherit DF bit from inner packet. */
> > +#define TNL_F_DF_DEFAULT	(1 << 4) /* Set DF bit if inherit off or
> > +                                      * not IP. */
> > +#define TNL_F_PMTUD		    (1 << 5) /* Enable path MTU discovery. */
> > +#define TNL_F_HDR_CACHE		(1 << 6) /* Enable tunnel header caching. */
> > +#define TNL_F_IPSEC		    (1 << 7) /* Traffic is IPsec encrypted. */
> > +#define TNL_F_IN_KEY	    (1 << 8) /* Tunnel port has input key. */
> > +#define TNL_F_OUT_KEY	    (1 << 9) /* Tunnel port has output key. */
> 
> Some of the above definitions use all spaces, others use tabs.  It's
> OVS userspace code so it's better to use all spaces, I think.

Sorry about that. I have a bit of trouble remembering to switch
tabbing modes in my editor depending on if I am in user-space or the
datapath.

> > +    if (is_ipsec) {
> > +        char *file_name = xasprintf("%s/%s", ovs_rundir(),
> > +                "ovs-monitor-ipsec.pid");
> > +        pid_t pid = read_pidfile(file_name);
> > +        free(file_name);
> > +        if (pid < 0) {
> > +            VLOG_ERR("%s: IPsec requires the ovs-monitor-ipsec daemon",
> > +                     iface_cfg->name);
> > +            goto err;
> > +        }
> 
> I just noticed that we re-read this pidfile every time we parse an
> IPsec tunnel.  I guess that would be a big waste of time if we have a
> lot of IPsec tunnels.  I'll make a note to consider fixing this
> separately (it's not your problem).

I guess that it should be easy enough to set a flag if any of the parsed
configurations use ipsec and perform the pid check if so.

As it is, I wouldn't be at all surprised if my series breaks ipsec as
I haven't tested it (with or without my changes).
