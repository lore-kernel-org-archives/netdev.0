From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v2 1/5] drivers: phy: add generic PHY framework
Date: Sat, 23 Feb 2013 16:44:40 -0600
Message-ID: <1361659480.11282.15@driftwood>
References: <1361253198-7401-2-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: tony@atomide.com, linux@arm.linux.org.uk, eballetbo@gmail.com,
	javier@dowhile0.org, kishon@ti.com, balbi@ti.com,
	gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mchehab@redhat.com, cesarb@cesarb.net, davem@davemloft.net,
	arnd@arndb.de, santosh.shilimkar@ti.com,
	broonie@opensource.wolfsonmicro.com, swarren@nvidia.com,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1361253198-7401-2-git-send-email-kishon@ti.com> (from
	kishon@ti.com on Mon Feb 18 23:53:14 2013)
Content-Disposition: inline
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 11:53:14 PM, Kishon Vijay Abraham I wrote:
> The PHY framework provides a set of APIs for the PHY drivers to
> create/destroy a PHY and APIs for the PHY users to obtain a reference  
> to the
> PHY with or without using phandle. To obtain a reference to the PHY  
> without
> using phandle, the platform specfic intialization code (say from  
> board file)
> should have already called phy_bind with the binding information. The  
> binding
> information consists of phy's device name, phy user device name and  
> an index.
> The index is used when the same phy user binds to mulitple phys.

Given that this has a separately selectable config option, I'm guessing  
that it's useful all by itself even in the absence of a driver using  
this phy? (Or it gives user visibility to the phy buried in an E1000 or  
SATA drive or some such?)

> +1. Introduction
> +
> +*PHY* is the abbreviation for physical layer. It is used to connect  
> a device
> +to the physical medium e.g., the USB controller has a PHY to provide  
> functions
> +such as serialization, de-serialization, encoding, decoding and is  
> responsible
> +for obtaining the required data transmission rate. Note that some USB
> +controller has PHY functionality embedded into it and others use an  
> external
> +PHY. Other peripherals that uses a PHY include Wireless LAN,  
> Ethernet,
> +SATA etc.

I've usually heard the word "transciever" used to describe these.

> +The intention of creating this framework is to bring the phy drivers  
> spread
> +all over the Linux kernel to drivers/phy to increase code re-use and  
> to
> +increase code maintainability.
> +
> +This framework will be of use only to devices that uses external PHY  
> (PHY
> +functionality is not embedded within the controller).
> +
> +2. Creating the PHY
> +
> +The PHY driver should create the PHY in order for other peripheral  
> controllers
> +to make use of it. The PHY framework provides 2 APIs to create the  
> PHY.

Given that a PHY is a chip (random example  
http://ark.intel.com/products/47620/Intel-82579LM-Gigabit-Ethernet-PHY),  
you seem to be saying that software should manifest a piece of hardware  
out of thin air through sheer willpower. I'm pretty sure I've  
misunderstood this phrasing.

> +struct phy *phy_create(struct device *dev, struct phy_descriptor  
> *desc);
> +struct phy *devm_phy_create(struct device *dev, struct  
> phy_descriptor *desc);
> +
> +The PHY drivers can use one of the above 2 APIs to create the PHY by  
> passing

Um, the driver should _bind_ to the phy, maybe? Allocate? Initialize?

> +6. Destroying the PHY

I've run drivers like that. I try not to, though.

> +7. Current Status
> +
> +Currently only USB in OMAP is made to use this framework. However  
> using the
> +USB PHY library cannot be completely removed because it is  
> intertwined with
> +OTG. Once we move OTG out of PHY completely, using the old PHY  
> library can be
> +completely removed. SATA in OMAP will also more likely use this new  
> framework
> +and we should have a patch for it soon.

Does this paragraph belong in the documentation? (Git commit, sure, but  
I've seen a lot of stale paragraphs like these hang around a  
surprisingly long time.)

Rob