From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 10/12] net: dsa: mv88e6xxx: iterate on
 compatible info
Date: Tue, 14 Jun 2016 23:46:58 +0200
Message-ID: <20160614214658.GG12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-11-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46183 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382AbcFNVrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 17:47:01 -0400
Content-Disposition: inline
In-Reply-To: <20160614183153.32327-11-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 02:31:51PM -0400, Vivien Didelot wrote:
> With legacy probing, we cannot have a compatible info structure. We have
> to guess it. Instead of using only the first info structure of the info
> table, iterate over the compatible data.
> 
> That way, the legacy code will support new compatible chips with
> different register access without requiring any code change.

I don't think this is safe when used in combination with multi-chip
addresses. This code will perform writes on various addresses,
addresses which could be real registers on a device.

I don't see a need to support guessing. The new binding will work,
without any guessing. So use that.

	Andrew
