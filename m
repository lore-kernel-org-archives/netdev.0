From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/5] ARM: Berlin: Ethernet support
Date: Fri, 29 Aug 2014 18:47:17 +0200
Message-ID: <5400AE95.2040308@gmail.com>
References: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409320263-10295-1-git-send-email-antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/29/2014 03:50 PM, Antoine Tenart wrote:
> This series introduce the Marvell Berlin Ethernet driver, allowing to
> handle the fast Ethernet port. This driver is based on the mv643xx_eth
> driver and reuse some of its functions. While I wanted to make these
> functions common to the two drivers at first, I finally do think this
> is not a great idea:
> - Registers are very different.
> - The mv643xx_eth supports up to 1000Mbps interfaces and performance
>   issues may occur, whereas the mvberlin_eth is only for fast Ethernet.
> - The mvberlin_eth driver uses a hash table to filter incoming packets.
> - A few other differences.
> 
> I tried to stay close to the mv643xx_eth implementation, so that the
> discussion is still open, but I still ended up with lots of tiny
> differences that can be hard to manage for both cases. In the end I do
> think having two separate drivers is a good choice.

Antoine,

first of all, thanks a lot for providing this driver! I checked the
usual Marvell datasheets to see where the ethernet IP in Berlin comes
from and I hate to say it but it very much looks like PXA168, see [1]
A.22. Also, there is already a driver for pxa168_eth available.

I'll test and review you current driver on BG2 asap, but I guess it
should be merged with pxa168_eth _if_ the registers are really
compatible.

Sebastian

[1]
http://www.marvell.com/application-processors/armada-100/assets/armada_16x_software_manual.pdf

> That being said, I tested the Ethernet communication with ICMP pings,
> netcat, tried to use some network related softwares (such as ssh). Here
> is an iperf output:
> 
>  ------------------------------------------------------------
>  Client connecting to 192.168.0.11, TCP port 5001
>  TCP window size: 85.0 KByte (default)
>  ------------------------------------------------------------
>  [  3] local 192.168.0.20 port 44183 connected with 192.168.0.11 port 5001
>  [ ID] Interval       Transfer     Bandwidth
>  [  3]  0.0-10.0 sec   113 MBytes  94.8 Mbits/sec
> 
> Tests were done on a BG2Q DMP, and this series currently does not add
> other device tree nodes than the ones for this board.
> 
> Thanks!
> 
> Antoine
> 
> 
> Antoine Tenart (5):
>   net: mvberlin_eth: add an Ethernet driver for Marvell Berlin
>   Documentation: bindings: net: add the Marvell Berlin Ethernet
>     controller
>   Documentation: devicetree: net: mention Marvell Berlin
>   ARM: dts: berlin: add ethernet and mdio nodes
>   ARM: dts: berlin: enable the Ethernet port on the BG2Q DMP
> 
>  .../devicetree/bindings/net/marvell-berlin.txt     |   23 +
>  .../devicetree/bindings/net/marvell-orion-mdio.txt |    6 +-
>  arch/arm/boot/dts/berlin2q-marvell-dmp.dts         |   13 +
>  arch/arm/boot/dts/berlin2q.dtsi                    |   19 +
>  drivers/net/ethernet/marvell/Kconfig               |    9 +
>  drivers/net/ethernet/marvell/Makefile              |    1 +
>  drivers/net/ethernet/marvell/mvberlin_eth.c        | 2081 ++++++++++++++++++++
>  7 files changed, 2149 insertions(+), 3 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/marvell-berlin.txt
>  create mode 100644 drivers/net/ethernet/marvell/mvberlin_eth.c
> 

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
