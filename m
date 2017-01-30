From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH V2 net-next 1/2] qed: Add support for
 hardware offloaded FCoE.
Date: Mon, 30 Jan 2017 10:44:33 +0100
Message-ID: <bdcd89cf-85cc-5eb9-d3b1-d42bbb34c973@suse.de>
References: <1485376423-18737-1-git-send-email-chad.dupuis@cavium.com>
 <1485376423-18737-2-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1485376423-18737-2-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 01/25/2017 09:33 PM, Dupuis, Chad wrote:
> From: Arun Easi <arun.easi-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> =

> This adds the backbone required for the various HW initalizations
> which are necessary for the FCoE driver (qedf) for QLogic FastLinQ
> 4xxxx line of adapters - FW notification, resource initializations, etc.
> =

> Signed-off-by: Arun Easi <arun.easi-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Yuval Mintz <yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/qlogic/Kconfig               |   3 +
>  drivers/net/ethernet/qlogic/qed/Makefile          |   1 +
>  drivers/net/ethernet/qlogic/qed/qed.h             |  11 +
>  drivers/net/ethernet/qlogic/qed/qed_cxt.c         |  98 ++-
>  drivers/net/ethernet/qlogic/qed/qed_cxt.h         |   3 +
>  drivers/net/ethernet/qlogic/qed/qed_dcbx.c        |  13 +-
>  drivers/net/ethernet/qlogic/qed/qed_dcbx.h        |   5 +-
>  drivers/net/ethernet/qlogic/qed/qed_dev.c         | 205 ++++-
>  drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |  42 +
>  drivers/net/ethernet/qlogic/qed/qed_fcoe.c        | 990 ++++++++++++++++=
++++++
>  drivers/net/ethernet/qlogic/qed/qed_fcoe.h        |  52 ++
>  drivers/net/ethernet/qlogic/qed/qed_hsi.h         | 781 ++++++++++++++++-
>  drivers/net/ethernet/qlogic/qed/qed_hw.c          |   3 +
>  drivers/net/ethernet/qlogic/qed/qed_ll2.c         |  25 +
>  drivers/net/ethernet/qlogic/qed/qed_ll2.h         |   2 +-
>  drivers/net/ethernet/qlogic/qed/qed_main.c        |   7 +
>  drivers/net/ethernet/qlogic/qed/qed_mcp.c         |   3 +
>  drivers/net/ethernet/qlogic/qed/qed_mcp.h         |   1 +
>  drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |   8 +
>  drivers/net/ethernet/qlogic/qed/qed_sp.h          |   4 +
>  drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |   3 +
>  include/linux/qed/common_hsi.h                    |  10 +-
>  include/linux/qed/fcoe_common.h                   | 715 ++++++++++++++++
>  include/linux/qed/qed_fcoe_if.h                   | 145 ++++
>  include/linux/qed/qed_if.h                        |  41 +-
>  25 files changed, 3152 insertions(+), 19 deletions(-)
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.c
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.h
>  create mode 100644 include/linux/qed/fcoe_common.h
>  create mode 100644 include/linux/qed/qed_fcoe_if.h
> =

[ .. ]
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h b/drivers/net/eth=
ernet/qlogic/qed/qed_dcbx.h
> index d70300f..0fabe97 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
> +++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
> @@ -57,7 +57,6 @@ struct qed_dcbx_app_data {
>  	u8 tc;			/* Traffic Class */
>  };
>  =

> -#ifdef CONFIG_DCB
>  #define QED_DCBX_VERSION_DISABLED       0
>  #define QED_DCBX_VERSION_IEEE           1
>  #define QED_DCBX_VERSION_CEE            2
> @@ -73,7 +72,6 @@ struct qed_dcbx_set {
>  	struct qed_dcbx_admin_params config;
>  	u32 ver_num;
>  };
> -#endif
>  =

>  struct qed_dcbx_results {
>  	bool dcbx_enabled;
> @@ -97,9 +95,8 @@ struct qed_dcbx_info {
>  	struct qed_dcbx_results results;
>  	struct dcbx_mib operational;
>  	struct dcbx_mib remote;
> -#ifdef CONFIG_DCB
>  	struct qed_dcbx_set set;
> -#endif
> +	struct qed_dcbx_get get;
>  	u8 dcbx_cap;
>  };
>  =

Why did you remove the dependency on 'CONFIG_DCB'?

Other than that:

Reviewed-by: Hannes Reinecke <hare-IBi9RG/b67k@public.gmane.org>

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare-l3A5Bk7waGM@public.gmane.org			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: F. Imend=F6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=FCrnberg)
