From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Sat, 27 Aug 2016 16:38:49 +0100
Message-ID: <20160827153849.GA1041@n2100.armlinux.org.uk>
References: <20160825144314.1850730-1-arnd@arndb.de>
 <3062310.z9h3CgCZ7p@wuerfel>
 <87inuopw04.fsf@belgarion.home>
 <20160825223743.GK1041@n2100.armlinux.org.uk>
 <87vaymdyal.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
        linux-arm-kernel@lists.infradead.org,
        Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87vaymdyal.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 27, 2016 at 05:30:42PM +0200, Robert Jarzmik wrote:
> Hi Russell,
> 
> With your patch :
>  - lubbock, mainstone and zylonite boards are working correctly
>    => ie. all my boards are working correctly
> 
>  - the message "ifconfig: SIOCSIFHWADDR: Device or resource busy" is still there
>    => this message is here even without your patch, so it's rather not relevant
>    => this message is triggered by an "/sbin/ifconfig eth0 hw ether
>    08:00:3e:26:0a:5b" command
> 
> So from a PXA testing point of view it's all good, ie.
> Tested-by: Robert Jarzmik <robert.jarzmik@free.fr>

Thanks for testing, that's good news.

You'll get "SIOCSIFHWADDR: Device or resource busy" if the device is
already up and has no support for changing the address while the NIC
is "live" - we only program the MAC address when bringing the smc91x
device up (or resetting it after a timeout).

See net/ethernet/eth.c::eth_prepare_mac_addr_change() and smc_enable().

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
