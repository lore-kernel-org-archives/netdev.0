From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH v2] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 09 Nov 2011 13:27:40 -0500
Message-ID: <4EBAC61C.2020808@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com>  <20111026.194045.2019668159403582571.davem@davemloft.net>  <4EA8B283.3010105@teksavvy.com>  <20111026.221719.2216112919297458522.davem@davemloft.net>  <4EB19BBE.5050602@teksavvy.com>  <4EBAB8F5.1010101@teksavvy.com> <1320860857.2781.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michal Marek <mmarek@suse.cz>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320860857.2781.5.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-11-09 12:47 PM, Ben Hutchings wrote:
> On Wed, 2011-11-09 at 12:31 -0500, Mark Lord wrote:
> [...]
>> +static int ax88172_link_reset(struct usbnet *dev)
>> +{
>> +       u16 lpa;
>> +       u16 adv;
>> +       u16 res;
>> +       u8 mode;
>> +
>> +       mode = AX_MEDIUM_TX_ABORT_ALLOW | AX_MEDIUM_FLOW_CONTROL_EN;
>> +       lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
>> +       adv = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_ADVERTISE);
>> +       res = mii_nway_result(lpa|adv);
> [...]
> 
> The argument to mii_nway_result() must be lpa & adv (the intersection of
> supported modes, not the union!).


Excellent.  Fixed.
