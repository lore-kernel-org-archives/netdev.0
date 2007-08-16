From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: drivers/infiniband/mlx/mad.c misplaced ;
Date: Fri, 17 Aug 2007 01:19:37 +0900
Message-ID: <20070816161937.GA15530@linux-sh.org>
References: <exportbomb.1187270320@pinky> <20070815235825.GB17004@redhat.com> <1187224811.5906.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>, rolandd@cisco.com,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	isdn4linux@listserv.isdn4linux.de, mikep@linuxtr.net,
	netdev@vger.kernel.org, swen@vnet.ibm.com, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, jdike@karaya.com,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	netfilter-devel@lists.netfilter.org, coreteam@netfilter.org,
	Randy Dunlap <rdunlap@xenotime.net>,
	Andrew Morton <akpm@osdl.org>
To: Joe Perches <joe@perches.com>, Andy Whitcroft <apw@shadowen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ocgnet.org ([64.20.243.3]:33346 "EHLO smtp.ocgnet.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764719AbXHPQUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 12:20:46 -0400
Content-Disposition: inline
In-Reply-To: <exportbomb.1187270320@pinky> <1187224811.5906.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 05:40:11PM -0700, Joe Perches wrote:
> $ egrep -r --include=*.c "\bif[[:space:]]*\([^\)]*\)[[:space:]]*\;" * 
> arch/sh/boards/se/7343/io.c:    if (0) ;
> drivers/atm/iphase.c:     if (!desc1) ;
> drivers/infiniband/hw/mlx4/mad.c:       if (!err);
> drivers/isdn/capi/capiutil.c:   else if (c <= 0x0f);
> drivers/net/tokenring/ibmtr.c:  else if (ti->shared_ram_paging == 0xf);  /* No paging in adapter */
> drivers/s390/scsi/zfcp_erp.c:           if (status == ZFCP_ERP_SUCCEEDED) ;     /* no further action */
> fs/hostfs/hostfs_user.c:        if(attrs->ia_valid & HOSTFS_ATTR_CTIME) ;
> net/netfilter/xt_u32.c:         if (skb->len < 4 || pos > skb->len - 4);
> sound/pci/au88x0/au88x0_synth.c:                                if (eax == 0) ;

On Thu, Aug 16, 2007 at 02:18:40PM +0100, Andy Whitcroft wrote:
> A couple of people suggested adding checks to checkpatch for trailing
> semicolons on conditionals, where the conditional block may not be
> actually conditional:
> 
> 	if (err);
> 		return err;
> 
> While regression testing the changes, I ran these checks across the
> whole of 2.6.23-rc3 and there appear to be 5 places where this is
> occurs (above and beyond the IPv6 one which triggered this effort)
> and a benign use which could be confused later which it seems safest
> to fix.
> 
> Following this email are 6 patches for these issues, relevant
> maintainers cc'd.  All against 2.6.23-rc3
> 
It looks like you may want to refine your search parameters to match the
above, as there are at least a few cases where the space exists.
