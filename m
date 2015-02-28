From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH] sh_eth: Fix lost MAC address on kexec
Date: Sat, 28 Feb 2015 02:48:41 +0000
Message-ID: <1425091721.4444.91.camel@xylophone.i.decadent.org.uk>
References: <1425053786-24223-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Kevin Hilman <khilman@kernel.org>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425053786-24223-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-02-27 at 17:16 +0100, Geert Uytterhoeven wrote:
> Commit 740c7f31c094703c ("sh_eth: Ensure DMA engines are stopped before
> freeing buffers") added a call to sh_eth_reset() to the
> sh_eth_set_ringparam() and sh_eth_close() paths.
> 
> However, setting the software reset bit(s) in the EDMR register resets
> the MAC Address Registers to zero. Hence after kexec, the new kernel
> doesn't detect a valid MAC address and assigns a random MAC address,
> breaking DHCP.
[...]

Sorry about that.  This would also affect removing and reloading the
driver as a module, but currently I always have it built in and don't
use kexec.

Ben.
