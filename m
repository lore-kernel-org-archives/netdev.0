From: Tim Sander <tim01@iss.tu-darmstadt.de>
Subject: newbie: phy platform interrupt config
Date: Tue, 24 Jan 2012 15:37:10 +0100
Message-ID: <201201241537.17194.tim01@iss.tu-darmstadt.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richard.cochran@omicron.at>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Decotigny <decot@google.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I would like to set the interrupt for the phy on the i.mx35 pcm43 in the file 
arch/arm/mach-imx/mach-pcm043.c. Unfortunatly i didn't find a way to specify 
it. So i want to set the field (struct phy_device*)->irq.

What i managed so far is to request the gpio for the interrupt:
#define IMX_PHY_IRQ IMX_GPIO_NR(2,7)
gpio_request(IMX_PHY_IRQ, "FEC PHY irq");
gpio_direction_input(IMX_PHY_IRQ);

Now i guess the result of "gpio_to_irq(IMX_PHY_IRQ)" should go into some kind 
of argument to imx35_add_fec(pdata) which is a macro 
imx_add_fec(&imx35_fec_data, pdata).
pdata is of type (?) struct fec_platform_data which contains phy_interface_t 
and unsigned char array. So i don't see a way to set the phy interrupt there.

I tried search for a driver which set the phy irq but i didn't find any and 
setting the phy in the phy_fixup function is also not working since the 
interrupt seems not get registered when opening the device.

So how do i set the phy interrupt line in the platform file?

Best regards
Tim

PS:
The cc list is from scripts/get_maintainer.pl -f drivers/net/phy/ which are 
hopefully the right maintainers plus Andy Fleming which commited the 
documentation for libphy.
