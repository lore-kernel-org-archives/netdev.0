From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] VNIC: Adding support for Cavium ThunderX network
 controller
Date: Tue, 11 Nov 2014 13:39:21 -0500 (EST)
Message-ID: <20141111.133921.243613958949858000.davem@davemloft.net>
References: <1415596445-10061-1-git-send-email-rric@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, sassmann@redhat.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, sgoutham@cavium.com, rrichter@cavium.com
To: rric@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415596445-10061-1-git-send-email-rric@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rric@kernel.org>
Date: Sun,  9 Nov 2014 21:14:05 -0800

> +config NET_VENDOR_CAVIUM
 ...
> +config THUNDER_NIC_PF
...
> +config THUNDER_NIC_VF
 ...
> +config	THUNDER_NIC_BGX

These config options seem excessive, if not confusing.  What would a
distribution be expected to enable?  Everything?

> +# Don't change the order, NICPF driver is dependent on BGX driver init
> +obj-$(CONFIG_THUNDER_NIC_BGX) += thunder_bgx.o
> +obj-$(CONFIG_THUNDER_NIC_PF) += nicpf.o
> +obj-$(CONFIG_THUNDER_NIC_VF) += nicvf.o

Nothing ensures ordering if these things are built all modular.

Such ordering dependencies need to be resolved in another way.
