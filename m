From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 9 Nov 2011 17:47:37 +0000
Message-ID: <1320860857.2781.5.camel@bwh-desktop>
References: <4EA89972.5060101@teksavvy.com>
	 <20111026.194045.2019668159403582571.davem@davemloft.net>
	 <4EA8B283.3010105@teksavvy.com>
	 <20111026.221719.2216112919297458522.davem@davemloft.net>
	 <4EB19BBE.5050602@teksavvy.com>  <4EBAB8F5.1010101@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Michal Marek <mmarek@suse.cz>
To: Mark Lord <kernel@teksavvy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EBAB8F5.1010101@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-09 at 12:31 -0500, Mark Lord wrote:
[...]
> +static int ax88172_link_reset(struct usbnet *dev)
> +{
> +       u16 lpa;
> +       u16 adv;
> +       u16 res;
> +       u8 mode;
> +
> +       mode = AX_MEDIUM_TX_ABORT_ALLOW | AX_MEDIUM_FLOW_CONTROL_EN;
> +       lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
> +       adv = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_ADVERTISE);
> +       res = mii_nway_result(lpa|adv);
[...]

The argument to mii_nway_result() must be lpa & adv (the intersection of
supported modes, not the union!).

Ben

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
