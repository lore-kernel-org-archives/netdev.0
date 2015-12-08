From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 net-next 2/3] net: ethernet: cadence-macb: Add fallback to read DT provided caps
Date: Tue, 08 Dec 2015 16:00:20 +0100
Message-ID: <2217940.QPNsks7uyL@wuerfel>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com> <1449582726-6148-1-git-send-email-narmstrong@baylibre.com> <1449582726-6148-3-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org, joshc@ni.com
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449582726-6148-3-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 December 2015 14:52:05 Neil Armstrong wrote:
> Add 1:1 mapping of software defines caps parsing from DT in case the
> generic macb compatible form is used.
> These properties will provide support for futures implementations
> only defined from DT without need to update the driver code to support
> new variants.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> 

Translating the Linux implementation specific configuration into
DT properties directly is usually not the best way.

Could we instead have a lookup table by compatible string to set the
flags? It seems that there are lots of different flags but only a
couple of different users of this IP block. Also, the fact that
you are now adding yet another quirk tells me that the set you
define today is unlikely to cover all the future requirements.

	Arnd
