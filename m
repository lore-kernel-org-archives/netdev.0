From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 12/37] atl1c: restore max-read-request-size in Device
 Conrol Register
Date: Fri, 13 Apr 2012 18:02:43 +0100
Message-ID: <1334336563.2606.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
	 <1334276102-15866-13-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <qca-linux-team@qualcomm.com>,
	<nic-devel@qualcomm.com>, linux-pci <linux-pci@vger.kernel.org>
To: xiong <xiong@qca.qualcomm.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-13-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-04-13 at 08:14 +0800, xiong wrote:
> in some platforms, we found the max-read-request-size in Device Control
> Register is set to 0 by (BIOS?) during bootup, this will cause the
> performance(throughput) very bad.
> Restore it to a min-value.
> register definition of REG_DEVICE_CTRL is refined as well.
[...]

I'm guessing this memory-mapped register is an alias for the PCIe device
control register.  I think you should be using pcie_set_readrq() to
ensure that the final setting conforms to the device's Max Payload Size
and system policy.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
