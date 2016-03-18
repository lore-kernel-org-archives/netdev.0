From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v3] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Fri, 18 Mar 2016 16:07:29 -0500
Message-ID: <20160318210729.GA30163@rob-hp-laptop>
References: <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mkl@pengutronix.de, wg@grandegger.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, corbet@lwn.net,
	linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, geert+renesas@glider.be,
	chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2016 at 09:48:14AM +0000, Ramesh Shanmugasundaram wrote:
> This patch adds support for the CAN FD controller found in Renesas R-Car
> SoCs. The controller operates in CAN FD only mode by default.
> 
> CAN FD mode supports both Classical CAN & CAN FD frame formats. The
> controller supports ISO 11898-1:2015 CAN FD format only.
> 
> This controller supports two channels and the driver can enable either
> or both of the channels.
> 
> Driver uses Rx FIFOs (one per channel) for reception & Common FIFOs (one
> per channel) for transmission. Rx filter rules are configured to the
> minimum (one per channel) and it accepts Standard, Extended, Data &
> Remote Frame combinations.
> 
> Note: There are few documentation errors in R-Car Gen3 Hardware User
> Manual v0.5E with respect to CAN FD controller. They are listed below:
> 
> 1. CAN FD interrupt numbers 29 & 30 are listed as per channel
> interrupts. However, they are common to both channels (i.e.) they are
> global and channel interrupts respectively.
> 
> 2. CANFD clock is derived from PLL1. This is not documented.
> 
> 3. CANFD clock is further divided by (1/2) within the CAN FD controller.
> This is not documented.
> 
> 4. The minimum value of NTSEG1 in RSCFDnCFDCmNCFG register is 2 Tq. It
> is specified 4 Tq in the manual.
> 
> 5. The maximum number of message RAM area the controller can use is 3584
> bytes. It is specified 10752 bytes in the manual.
> 
> Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
> ---
> Hi All,
> 
>    Thanks for the review comments.
> 
>    This updated patch is based on linux-can-next tag (linux-can-next-for-4.6-20160310).
> 
>    This patch depends on
> 
>    [RFC] [PATCH v3] can: fix handling of unmodifiable configuration options
>    (http://comments.gmane.org/gmane.linux.can/9126)
> 
> Changes since v2:
> 	* Rebased to latest tag (linux-can-next-for-4.6-20160310)
> 	* Cleaned up leftover debugfs code (Thanks Oliver H)
> 	* Revised devicetree documentation text (as suggested by Rob H)
> 	  (https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg01597.html)
> 	* Used new can subsystem api to set static configuration & removed check in rcar_canfd_start (as suggested by Oliver H)
> 	  (Refer: http://comments.gmane.org/gmane.linux.can/9126 &
> 	   https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg01867.html)
> 	* Clubbed Renesas controller drivers to driver/net/can/rcar dir (as suggested by Oliver H)
> 	* Updated commit message
> 
> Changes since v1:
> 	* Removed testmodes & debugfs code (suggested by Oliver H)
> 	* Fixed tx path race issue by introducing lock (suggested by Marc K)
> 	* Removed __maybe_unused attribute of rcar_canfd_of_table
> ---
>  .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 ++

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/can/Kconfig                            |   11 +-
>  drivers/net/can/Makefile                           |    2 +-
>  drivers/net/can/rcar/Kconfig                       |   19 +
>  drivers/net/can/rcar/Makefile                      |    6 +
>  drivers/net/can/{ => rcar}/rcar_can.c              |    0
>  drivers/net/can/rcar/rcar_canfd.c                  | 1614 ++++++++++++++++++++
>  7 files changed, 1730 insertions(+), 11 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/can/rcar_canfd.txt
>  create mode 100644 drivers/net/can/rcar/Kconfig
>  create mode 100644 drivers/net/can/rcar/Makefile
>  rename drivers/net/can/{ => rcar}/rcar_can.c (100%)
>  create mode 100644 drivers/net/can/rcar/rcar_canfd.c
