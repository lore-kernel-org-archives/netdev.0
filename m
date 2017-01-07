From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv2 net-next 11/16] net: mvpp2: handle misc PPv2.1/PPv2.2
 differences
Date: Sat, 7 Jan 2017 09:38:34 +0000
Message-ID: <20170107093834.GJ14217@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-12-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Yehuda Yitschak <yehuday@marvell.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Andrew Lunn <andrew@lunn.ch>, Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1482943592-12556-12-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 28, 2016 at 05:46:27PM +0100, Thomas Petazzoni wrote:
> @@ -6511,7 +6515,9 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>  		dev_err(&pdev->dev, "failed to init port %d\n", id);
>  		goto err_free_stats;
>  	}
> -	mvpp2_port_power_up(port);
> +
> +	if (priv->hw_version == MVPP21)
> +		mvpp21_port_power_up(port);

This has the side effect that nothing clears the port reset bit in the
GMAC, which means there's no hope of the interface working - with the
reset bit set, the port is well and truely held in "link down" state.

In any case, the GMAC part is much the same as mvneta, and I think
that code should be shared rather than writing new versions of it.
There are some subtle differences between neta, pp2.1 and pp2.2, but
it's entirely doable (I have an implementation here as I wasn't going
to duplicate this code for my phylink conversion.)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
