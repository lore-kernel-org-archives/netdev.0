From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: add SERDES registers to debugfs
Date: Wed, 8 Jul 2015 23:08:51 +0200
Message-ID: <20150708210851.GI1357@lunn.ch>
References: <1436387779-23407-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1436387779-23407-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436387779-23407-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 08, 2015 at 04:36:19PM -0400, Vivien Didelot wrote:
> Add read and write access to a SERDES column in the regs debugfs file
> for the Fiber/SERDES registers.


Humm. I don't really like this. These SERDES registers are in a
complete different address space to the port, globalX registers. I
would suggest adding a new file, 'phy', which allows access to all the
phy registers, and SERDES at 0x0f.

This also makes it simpler to deal with devices which don't have
indirect access to the PHYs via Global 2 offset 0x18 and 0x19. For
such chips, the debugfs file should not be created.

Thanks
	Andrew
