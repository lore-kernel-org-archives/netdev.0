From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/8] net: extend ethtool link mode bitmaps
 to 48 bits
Date: Tue, 06 Jan 2015 17:29:18 -0500 (EST)
Message-ID: <20150106.172918.70204012105519766.davem@davemloft.net>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
	<54ABE991.3040107@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, yamato-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	xii-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teg-B22kvLQNl6c@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org,
	_govind-KK0ffGbhmjU@public.gmane.org
To: amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54ABE991.3040107-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Tue, 6 Jan 2015 15:56:33 +0200

> Mellanox is about to release next month a driver for a new NIC, with 3
> new speeds * few link modes for each + new link modes for 10G.
> It seems that we will need to consume almost all the new bits.

This tells me that the approach to this problem needs to be rethought.

Maybe we just need to bite the bullet and make a new ETHTOOL_GSET_2
and ETHTOOL_SSET_2 or whatever you want to name them.

Then we can define a completely new structure, with 64-bit bitmaps
for link modes or whatever.  The ethtool_op callbacks work using
this structure, and only the net/core/ethtool.c code knows about
the older structure and translates to/from for ETHTOOL_{GSET,SSET}.
