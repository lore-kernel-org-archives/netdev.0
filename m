From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: lan9303: Do not disable switch fabric
 port 0 at .probe
Date: Tue, 24 Oct 2017 18:27:02 +0200
Message-ID: <20171024162702.GA12347@lunn.ch>
References: <20171024151410.28494-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171024151410.28494-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 05:14:10PM +0200, Egil Hjelmeland wrote:
> Make the LAN9303 work when lan9303_probe() is called twice.
> 
> For some unknown reason the LAN9303 switch fail to forward data when switch
> fabric port 0 TX is disabled during probe. (Write of LAN9303_MAC_TX_CFG_0
> in lan9303_disable_processing_port().)
> 
> In that situation the switch fabric seem to receive frames, because the ALR
> is learning addresses. But no frames are transmitted on any of the ports.
> 
> In our system lan9303_probe() is called twice, first time
> dsa_register_switch() return -EPROBE_DEFER. As an experiment, modified the
> code to skip writing LAN9303_MAC_TX_CFG_0, port 0 during the first probe.
> Then the switch works as expected.
> 
> Resolve the problem by not calling lan9303_disable_processing_port() on
> port 0 during probe. Ports 1 and 2 are still disabled.
> 
> Although unsatisfying that the exact failure mechanism is not known,
> the patch should not cause any harm.

I agree about this being unsatisfying, but as you said, it fixed your
issue, and it probably does not cause other issues.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
