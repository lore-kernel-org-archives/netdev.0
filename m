From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] net: dsa: don't unmask port bitmaps
Date: Mon, 23 Oct 2017 23:11:09 +0200
Message-ID: <20171023211109.GA23689@lunn.ch>
References: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:55977 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751723AbdJWVLO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 17:11:14 -0400
Content-Disposition: inline
In-Reply-To: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 02:17:29PM -0400, Vivien Didelot wrote:
> DSA has several bitmaps to store the type of ports: cpu_port_mask,
> dsa_port_mask and enabled_port_mask. But the code is inconsistently
> unmasking them.
> 
> The legacy code tries to unmask cpu_port_mask and dsa_port_mask but
> skips enabled_port_mask.
> 
> The new bindings unmasks cpu_port_mask and enabled_port_mask but skips
> dsa_port_mask.
> 
> In fact there is no need to unmask them because we are in the error
> path, and they won't be used after. Instead of fixing the unmasking,
> simply remove them.

Hi Vivien

I'm not looked at the code, travelling and don't have time.

What happens if the failure is -PROBE_DEFERRED, and it tried again
later. Will these masks be set back to 0? Or will they retain the old
values? I think there is supposed to be symmetry here, so that we undo
what we did, and so the next time we try again, we start from a good
state.

	Andrew
