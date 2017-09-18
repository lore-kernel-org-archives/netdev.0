From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 16/16] thunderbolt: Add support for networking over
 Thunderbolt cable
Date: Tue, 19 Sep 2017 01:21:44 +0200
Message-ID: <20170918232144.GD29615@lunn.ch>
References: <20170918153049.44185-1-mika.westerberg@linux.intel.com>
 <20170918153049.44185-17-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mika Westerberg <mika.westerberg@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170918153049.44185-17-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 06:30:49PM +0300, Mika Westerberg wrote:
> From: Amir Levy <amir.jer.levy@intel.com>
> 
> ThunderboltIP is a protocol created by Apple to tunnel IP/ethernet
> traffic over a Thunderbolt cable. The protocol consists of configuration
> phase where each side sends ThunderboltIP login packets (the protocol is
> determined by UUID in the XDomain packet header) over the configuration
> channel. Once both sides get positive acknowledgment to their login
> packet, they configure high-speed DMA path accordingly. This DMA path is
> then used to transmit and receive networking traffic.
> 
> This patch creates a virtual ethernet interface the host software can
> use in the same way as any other networking interface. Once the
> interface is brought up successfully network packets get tunneled over
> the Thunderbolt cable to the remote host and back.
> 
> The connection is terminated by sending a ThunderboltIP logout packet
> over the configuration channel. We do this when the network interface is
> brought down by user or the driver is unloaded.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> Signed-off-by: Michael Jamet <michael.jamet@intel.com>
> Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
> Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
> ---
>  Documentation/admin-guide/thunderbolt.rst |   24 +
>  drivers/thunderbolt/Kconfig               |   12 +
>  drivers/thunderbolt/Makefile              |    3 +
>  drivers/thunderbolt/net.c                 | 1392 +++++++++++++++++++++++++++++
>  4 files changed, 1431 insertions(+)
>  create mode 100644 drivers/thunderbolt/net.c

Hi Mika

Could this be renamed to driver/net/thunderbolt.c?

At minimum, it needs a MAINTAINER entry pointing to netdev, so patches
get reviewed by netdev people. However, since the driver seems to be a
lot more netdev than thunderbolt, placing it in driver/net could be
better.

	Thanks
		Andrew
