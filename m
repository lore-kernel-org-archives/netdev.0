From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next v4 0/3] can: mscan-mpc5xxx: add support for the
	Freescale MPC512x
Date: Thu,  7 Jan 2010 20:43:05 +0100
Message-ID: <1262893388-16218-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series adds support for the MPC512x from Freescale to the
mpc5xxx_can MSCAN driver. It has been tested on a MPC5121 and MPC5200B
board.

Changes since v3:

- drop invalid skb packets in mscan_start_xmit() silently as suggested
  by David Miller in the thread "[RFC] ndo_validate_skb: Let the netdev
  check a valid skb content".

Changes since v2:

- Debugging code just for development has beem removed.
- Bus-off recovery tested and fixed for MPC5121.

Changes since v1:

- Various coding style issues, print formats, variable names, error
  messages and typos fixes or improved.

- MPC5xxx specific data are now passed to mpc5xxx_can_probe() via
  "of_device_id->data".

- The index of the MPC512x CAN controller is now derived directly
  from the reg property. This allows using of_iomap() as before.

- It has been documented that MPC512x Rev.1 CPUs are not supported.

Wolfgang

Wolfgang Grandegger (3):
  can: mscan: fix improper return if dlc < 8 in start_xmit function
  can: mscan-mpc5xxx: add support for the MPC512x processor
  powerpc/mpc5xxx: add OF platform binding doc for FSL MSCAN devices

 Documentation/powerpc/dts-bindings/fsl/can.txt     |   53 +++++
 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +-
 drivers/net/can/mscan/Kconfig                      |    7 +-
 drivers/net/can/mscan/mpc5xxx_can.c                |  246 ++++++++++++++++----
 drivers/net/can/mscan/mscan.c                      |   60 ++++-
 drivers/net/can/mscan/mscan.h                      |   86 ++++----
 6 files changed, 355 insertions(+), 106 deletions(-)
 create mode 100644 Documentation/powerpc/dts-bindings/fsl/can.txt
