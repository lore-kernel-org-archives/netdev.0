From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Mon, 7 Nov 2011 23:18:23 +0100
Message-ID: <20111107221823.GE1833899@jupiter.n2.diac24.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
 <1320512055-1231037-2-git-send-email-equinox@diac24.net>
 <20111107134401.21cb3bf0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:42767 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab1KGWS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 17:18:29 -0500
Content-Disposition: inline
In-Reply-To: <20111107134401.21cb3bf0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2011 at 01:44:01PM -0800, Stephen Hemminger wrote:
> On Sat,  5 Nov 2011 17:54:14 +0100
> David Lamparter <equinox@diac24.net> wrote:
> 
> > +#define vlangrp_for_each_dev(i, grp, vlandev) \
> > +	for (i = 0; i < VLAN_N_VID * VLAN_N_PROTOCOL; i++) \
> > +		if ((vlandev = vlan_group_get_device_pidx(grp, \
> > +					i / VLAN_N_VID, i % VLAN_N_VID)))
> > +			/* { code here } */
> > +
> 
> Please just open code this. Macro's make the code harder
> to parse for humans. There are a few exceptions like.
>   LIST_FOREACH_RCU()

That macro is the same kind as LIST_FOREACH_RCU, as its name says, a
"for_each" wrapper. I think it actually makes the code easier to read.
Plus, if the code is there 10 times instead of one, that's 10 times the
chance to break one of the copypastas.

A quick "git grep -i '#define.*for.*each'" indicates that this kind
of macro is quite common with 428 grep results
(e.g. bond_for_each_slave, for_each_sas_task, ...)


-David
