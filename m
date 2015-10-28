From: David Jander <david@protonic.nl>
Subject: BUG: fsl FEC ethernet tx checksum offloading doesn't work with RMII
 interface
Date: Wed, 28 Oct 2015 10:48:54 +0100
Message-ID: <20151028104854.025430ce@archvile>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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


Hi all,

I was unable to figure out who's maintaining
drivers/net/ethernet/freescale/fec_main.c, so I hope someone can help out on
this list...

We have a board with a RMII phy connected to an i.MX6S. The hardware seems to
be ok, since I can receive and transmit ethernet frames without drops or
errors. However only simple things like ping and dhcp seemed to work. TCP/IP
connections could not be made. When looking at both ends with tcpdump, I
realized that all transmitted packages arrived at the other end with the TCP
and IP header checksums zeroed-out.

After issuing the following command, TCP/IP started working correctly:

$ ethtool --offload eth0 tx off

This works around the issue. For some reason, when the FEC is in RMII mode, it
isn't filling in the checksums.

On another board with an RGMII phy the same kernel works fine without the need
to disable offloading. What can possibly relate this functionality to the
choice of MAC interface?

Best regards,

-- 
David Jander
Protonic Holland.
