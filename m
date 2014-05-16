From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Don't call phy_resume if phy_init_hw failed
Date: Thu, 15 May 2014 22:57:15 -0400 (EDT)
Message-ID: <20140515.225715.1311338998569156758.davem@davemloft.net>
References: <1400098369-13985-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400098369-13985-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 14 May 2014 13:12:49 -0700

> After the call to phy_init_hw failed in phy_attach_direct, phy_detach is called
> to detach the phy device from its network device. If the attached driver is a
> generic phy driver, this also detaches the driver. Subsequently phy_resume
> is called, which assumes without checking that a driver is attached to the
> device. This will result in a crash such as
> 
> Unable to handle kernel paging request for data at address 0xffffffffffffff90
> Faulting instruction address: 0xc0000000003a0e18
> Oops: Kernel access of bad area, sig: 11 [#1]
> ...
> NIP [c0000000003a0e18] .phy_attach_direct+0x68/0x17c
> LR [c0000000003a0e6c] .phy_attach_direct+0xbc/0x17c
> Call Trace:
> [c0000003fc0475d0] [c0000000003a0e6c] .phy_attach_direct+0xbc/0x17c (unreliable)
> [c0000003fc047670] [c0000000003a0ff8] .phy_connect_direct+0x28/0x98
> [c0000003fc047700] [c0000000003f0074] .of_phy_connect+0x4c/0xa4
> 
> Only call phy_resume if phy_init_hw was successful.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied and queued up for -stable, thanks.
