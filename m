From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] ethtool: fix ethtool_get_regs() to work with zero length
 registers
Date: Wed, 20 Jul 2011 14:58:20 +0300
Message-ID: <4E26C2DC.8090208@qca.qualcomm.com>
References: <20110720091850.32210.2059.stgit@localhost6.localdomain6> <1311161889.1041.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311161889.1041.11.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/20/2011 02:38 PM, Ben Hutchings wrote:
> On Wed, 2011-07-20 at 12:18 +0300, Kalle Valo wrote:
>> cfg80211 exports zero length register size as it currently only uses
>> struct ethtool_regs.version to export struct wiphy.hw_version.
> [...]
> 
> The ethtool_regs::version field represents the version of the register
> dump format.  This may or may not relate to a hardware version.
> 
> If you don't actually provide a register dump then don't implement this
> operation.

Then we have a problem as cfg80211 exports the hw version without any
register dumps:

static int cfg80211_get_regs_len(struct net_device *dev)
{
	/* For now, return 0... */
	return 0;
}

static void cfg80211_get_regs(struct net_device *dev, struct
ethtool_regs *regs,
			void *data)
{
	struct wireless_dev *wdev = dev->ieee80211_ptr;

	regs->version = wdev->wiphy->hw_version;
	regs->len = 0;
}

And this has been there a long time already. How cfg80211 should export
hw version if this is not a proper way?

Kalle
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
