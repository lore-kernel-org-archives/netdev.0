From: Rabin Vincent <rabin@rab.in>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Sat, 19 Nov 2016 14:56:54 +0100
Message-ID: <20161119135654.GA14079@lnxartpec.se.axis.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mued dib <kreptor@gmail.com>, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
        saeedm@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, CARLOS.PALMINHA@synopsys.com,
        andreas.irestal@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, lars.persson@axis.com
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34536 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752724AbcKSN5B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:57:01 -0500
Content-Disposition: inline
In-Reply-To: <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2016 at 02:20:27PM +0000, Joao Pinto wrote:
> For now we are interesting in improving the synopsys QoS driver under
> /nect/ethernet/synopsys. For now the driver structure consists of a single file
> called dwc_eth_qos.c, containing synopsys ethernet qos common ops and platform
> related stuff.
> 
> Our strategy would be:
> 
> a) Implement a platform glue driver (dwc_eth_qos_pltfm.c)
> b) Implement a pci glue driver (dwc_eth_qos_pci.c)
> c) Implement a "core driver" (dwc_eth_qos.c) that would only have Ethernet QoS
> related stuff to be reused by the platform / pci drivers
> d) Add a set of features to the "core driver" that we have available internally

Note that there are actually two drivers in mainline for this hardware:

 drivers/net/ethernet/synopsis/
 drivers/net/ethernet/stmicro/stmmac/

(See http://lists.openwall.net/netdev/2016/02/29/127)

The former only supports 4.x of the hardware.

The later supports 4.x and 3.x and already has a platform glue driver
with support for several platforms, a PCI glue driver, and a core driver
with several features not present in the former (for example: TX/RX
interrupt coalescing, EEE, PTP).

Have you evaluated both drivers?  Why have you decided to work on the
former rather than the latter?
