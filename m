From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH 1/2] gianfar: Deal with link state changes during
 GFAR_RESETTING dev state
Date: Mon, 13 Feb 2017 17:10:25 +0000
Message-ID: <AM5PR0401MB25617858360C598BC3146E9096590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1486988529-24924-1-git-send-email-thomas.graziadei@omicronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Thomas Graziadei <thomas.graziadei@omicronenergy.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486988529-24924-1-git-send-email-thomas.graziadei@omicronenergy.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Thomas Graziadei [mailto:thomas.graziadei@omicronenergy.com]
>Sent: Monday, February 13, 2017 2:22 PM
>To: claudiu.manoil@freescale.com; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Cc: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
>Subject: [PATCH 1/2] gianfar: Deal with link state changes during GFAR_RES=
ETTING
>dev state
>
>From: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
>
>The link state is not correctly set in the case that the network driver
>is reconfigured while the link state changes. The phy informs the gianfar
>driver, but gfar_update_link_state just exits and therefore looses the
>change event. The network driver remains in the old state until a new link
>event is sent.
>
>A trace log from a possible scenario at bootup, when the link state in the
>network driver stays down even though the phy reports an up link. The test
>sends a SIOCSHWTSTAMP ioctl at the right moment (which calls reset_gfar):
>         ip-1196 [000]  5.389270: phy_start: state: READY -> UP
>kworker/0:2-1195 [000]  5.389784: phy_start_aneg: state: UP -> AN
>kworker/0:2-1195 [000]  5.389788: phy_state_machine: state: UP -> AN
>kworker/0:2-1195 [000]  6.828064: adjust_link: eth0, link 0 -> 0
>kworker/0:2-1195 [000]  6.828599: phy_state_machine: state: AN -> NOLINK
>       test-1470 [000]  7.460422: reset_gfar: before locking GFAR_RESETTIN=
G
>       test-1470 [000]  7.470806: phy_stop: state: NOLINK -> HALTED
>       test-1470 [000]  7.478806: phy_start: state: HALTED -> RESUMING
>kworker/0:2-1195 [000]  7.479478: adjust_link: eth0, link 0 -> 1
>kworker/0:2-1195 [000]  7.479482: phy_state_machine: state: RESUMING ->
>RUNNING
>       test-1470 [000]  7.479826: reset_gfar: after locking GFAR_RESETTING
>
>To resolve the issue adjust_link is called after every GFAR_RESETTING lock
>section. Adjust_link itself checks if anything has changed and updates the
>link accordingly.
>

Hi,
Interesting findings. I need more time to check the patches. Btw, we don't=
=20
use "//" for comments on netdev.

Thanks,
Claudiu
