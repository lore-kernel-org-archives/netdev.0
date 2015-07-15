From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: fix fid_mask when leaving bridge
Date: Wed, 15 Jul 2015 07:23:22 -0700
Message-ID: <20150715142322.GA32367@roeck-us.net>
References: <1436969227-30006-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436969227-30006-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 15, 2015 at 10:07:07AM -0400, Vivien Didelot wrote:
> The mv88e6xxx_priv_state structure contains an fid_mask, where 1 means
> the FID is free to use, 0 means the FID is in use.
> 
> This patch fixes the bit clear in mv88e6xxx_leave_bridge() when
> assigning a new FID to a port.
> 
> Example scenario: I have 7 ports, port 5 is CPU, port 6 is unused (no
> PHY). After setting the ports 0, 1 and 2 in bridge br0, and ports 3 and
> 4 in bridge br1, I have the following fid_mask: 0b111110010110 (0xf96).
> 
> Indeed, br0 uses FID 0, and br1 uses FID 3.
> 
> After setting nomaster for port 0, I get the wrong fid_mask: 0b10 (0x2).
> 
> With this patch we correctly get 0b111110010100 (0xf94), meaning port 0
> uses FID 1, br0 uses FID 0, and br1 uses FID 3.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Guenter Roeck <linux@roeck-us.net>
