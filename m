From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Thu, 19 May 2016 08:57:57 +0200
Message-ID: <1712340.89M2Ezzzk6@ws-stein>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com> <573C9738.4040402@gmail.com> <2a059454-279b-4ade-6f0e-837013bb323f@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew@lunn.ch,
	Mathias Kresin <openwrt@kresin.me>,
	Hauke Mehrtens <Hauke.Mehrtens@lantiq.com>
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2a059454-279b-4ade-6f0e-837013bb323f@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

On Thursday 19 May 2016 06:50:56, John Crispin wrote:
> On 18/05/2016 18:24, Florian Fainelli wrote:
> > CC'ing Andrew, John,
> 
> also CC'ing Matthias and Hauke. we have had a driver in OpenWrt/LEDE for
> several years that seems a little more complete than this one.
> 
> https://git.lede-project.org/?p=source.git;a=blob;f=target/linux/lantiq/patc
> hes-4.4/0023-NET-PHY-adds-driver-for-lantiq-PHY11G.patch;h=93bb4275ec1d261f3
> 98afb8fdc879c1dd973f997;hb=HEAD

Thanks for the link, I wasn't aware of that patch. I like it in general, but 
there are some things I'd like to get addressed first:
* vr9_gphy_of_reg_init() writes uncoditionally to led3h and led3l even on
  PEf7071 which does not have this register at all
* Why is PHY_HAS_INTERRUPT commented out everywhere?
* ltq_phy_init and ltq_phy_exit can be simplified using phy_drivers_register
  and phy_drivers_unregister
* A mdio_device_id table is missing

Best regards,
Alexander
