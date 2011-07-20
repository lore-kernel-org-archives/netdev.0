From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] ethtool: fix ethtool_get_regs() to work with zero length
 registers
Date: Wed, 20 Jul 2011 10:36:12 -0400
Message-ID: <20110720143611.GA18231@tuxdriver.com>
References: <20110720091850.32210.2059.stgit@localhost6.localdomain6>
 <1311161889.1041.11.camel@localhost>
 <4E26C2DC.8090208@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E26C2DC.8090208-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 20, 2011 at 02:58:20PM +0300, Kalle Valo wrote:
> On 07/20/2011 02:38 PM, Ben Hutchings wrote:
> > On Wed, 2011-07-20 at 12:18 +0300, Kalle Valo wrote:
> >> cfg80211 exports zero length register size as it currently only uses
> >> struct ethtool_regs.version to export struct wiphy.hw_version.
> > [...]
> > 
> > The ethtool_regs::version field represents the version of the register
> > dump format.  This may or may not relate to a hardware version.

This seems like a strange claim to make...?

struct ethtool_regs {
	__u32	cmd;
	__u32	version; /* driver-specific, indicates different chips/revs */
	__u32	len; /* bytes */
	__u8	data[0];
};

That "indicates different chips/revs" comment has been there at least
as long as the kernel has been in git (back to the 2.6.12 era).

> > If you don't actually provide a register dump then don't implement this
> > operation.
> 
> Then we have a problem as cfg80211 exports the hw version without any
> register dumps:
> 
> static int cfg80211_get_regs_len(struct net_device *dev)
> {
> 	/* For now, return 0... */
> 	return 0;
> }
> 
> static void cfg80211_get_regs(struct net_device *dev, struct
> ethtool_regs *regs,
> 			void *data)
> {
> 	struct wireless_dev *wdev = dev->ieee80211_ptr;
> 
> 	regs->version = wdev->wiphy->hw_version;
> 	regs->len = 0;
> }
> 
> And this has been there a long time already. How cfg80211 should export
> hw version if this is not a proper way?

The ethool binary already has support for the at76c50x_usb driver,
which uses this very mechanism in exactly this way.  I know this
worked previously, although I don't know what might have changed to
break it...?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
