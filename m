From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: mv88e6xxx: refactor FDB routines
Date: Tue, 4 Aug 2015 18:03:00 +0200
Message-ID: <20150804160300.GB28673@lunn.ch>
References: <1438670018-30501-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55363 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbbHDQKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:10:04 -0400
Content-Disposition: inline
In-Reply-To: <1438670018-30501-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2015 at 02:33:38AM -0400, Vivien Didelot wrote:
> Refactor mv88e6xxx_port_fdb_{add,del,getnext} to respect the new DSA
> switch driver FDB access routines.
> 
> The Marvell 88E6xxx switches support up to 4094 FIDs (from 1 to 0xfff;
> FID 0 means that multiple address databases are not being used). So
> change the fid_mask for a fid_bitmap of 4096 bits.
> 
> FIDs 1 to num_ports will be reserved for non-bridged ports and bridge
> groups (a bridge group gets the FID of its first member). The remaining
> bits will then be used for VLANs.
> 
> Also do not consider an address (yet) if it is trunk mapped.
> 
> This change is a need to welcome the future support for hardware VLANs.

This patch seems to contain more than one logical set of changes. That
is making it hard to review. Can you split it up a bit.

The GLOBAL_ATU_DATA_TRUNK stuff can be in a patch of its own.
unsigned char *addr to u8 addr[ETH_ALEN].
The change fid_mask to fid_bitmap
...
...
The refactoring

Basically, we want to see lots of little patches which are obvious
correct, rather than one big patch where it is not obvious.

Thanks
	Andrew
