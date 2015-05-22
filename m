From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH v5 2/3] if_link: Add control trust VF
Date: Fri, 22 May 2015 15:12:14 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A07892F950E@ORSMSX108.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB28C7@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64919 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756233AbbEVPMg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 11:12:36 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB28C7@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Hiroshi Shimamoto
> Sent: Tuesday, May 19, 2015 5:04 PM
> To: Kirsher, Jeffrey T; intel-wired-lan@lists.osuosl.org
> Cc: nhorman@redhat.com; jogreene@redhat.com; Choi, Sy Jong; Rony Efraim;
> David Miller; Linux Netdev List; Edward Cree; Or Gerlitz;
> sassmann@redhat.com
> Subject: [Intel-wired-lan] [PATCH v5 2/3] if_link: Add control trust VF
> 
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> 
> Add netlink directives and ndo entry to trust VF user.
> 
> This controls the special permission of VF user.
> The administrator will dedicatedly trust VF user to use some features
> which impacts security and/or performance.
> 
> The administrator never turn it on unless VF user is fully trusted.
> 

This patch looks pretty good to me - it definitely fills a requirement for our needs.

Acked-by: Greg Rose <gregory.v.rose@intel.com>

> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  3 +++
>  include/uapi/linux/if_link.h |  6 ++++++
>  net/core/rtnetlink.c         | 19 +++++++++++++++++--
>  4 files changed, 27 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h index
> da49299..f3d2d2f 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -15,5 +15,6 @@ struct ifla_vf_info {
>  	__u32 min_tx_rate;
>  	__u32 max_tx_rate;
>  	__u32 rss_query_en;
> +	__u32 trusted;
>  };
>  #endif /* _LINUX_IF_LINK_H */
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h index
> 51f8d2f..0875149 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -873,6 +873,7 @@ typedef u16 (*select_queue_fallback_t)(struct
> net_device *dev,
>   * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int
> min_tx_rate,
>   *			  int max_tx_rate);
>   * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool
> setting);
> + * int (*ndo_set_vf_trust)(struct net_device *dev, int vf, bool
> + setting);
>   * int (*ndo_get_vf_config)(struct net_device *dev,
>   *			    int vf, struct ifla_vf_info *ivf);
>   * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int
> link_state); @@ -1095,6 +1096,8 @@ struct net_device_ops {
>  						   int max_tx_rate);
>  	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
>  						       int vf, bool setting);
> +	int			(*ndo_set_vf_trust)(struct net_device *dev,
> +						    int vf, bool setting);
>  	int			(*ndo_get_vf_config)(struct net_device *dev,
>  						     int vf,
>  						     struct ifla_vf_info *ivf);
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index afccc93..f05549c 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -480,6 +480,7 @@ enum {
>  	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
>  				 * on/off switch
>  				 */
> +	IFLA_VF_TRUST,		/* Trust VF */
>  	__IFLA_VF_MAX,
>  };
> 
> @@ -529,6 +530,11 @@ struct ifla_vf_rss_query_en {
>  	__u32 setting;
>  };
> 
> +struct ifla_vf_trust {
> +	__u32 vf;
> +	__u32 setting;
> +};
> +
>  /* VF ports management section
>   *
>   *	Nested layout of set/get msg is:
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c index
> 141ccc3..1d9205a 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -819,7 +819,8 @@ static inline int rtnl_vfinfo_size(const struct
> net_device *dev,
>  			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
>  			 nla_total_size(sizeof(struct ifla_vf_rate)) +
>  			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
> -			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)));
> +			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)) +
> +			 nla_total_size(sizeof(struct ifla_vf_trust)));
>  		return size;
>  	} else
>  		return 0;
> @@ -1138,6 +1139,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb,
> struct net_device *dev,
>  			struct ifla_vf_spoofchk vf_spoofchk;
>  			struct ifla_vf_link_state vf_linkstate;
>  			struct ifla_vf_rss_query_en vf_rss_query_en;
> +			struct ifla_vf_trust vf_trust;
> 
>  			/*
>  			 * Not all SR-IOV capable drivers support the @@ -1147,6
> +1149,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct
> net_device *dev,
>  			 */
>  			ivi.spoofchk = -1;
>  			ivi.rss_query_en = -1;
> +			ivi.trusted = -1;
>  			memset(ivi.mac, 0, sizeof(ivi.mac));
>  			/* The default value for VF link state is "auto"
>  			 * IFLA_VF_LINK_STATE_AUTO which equals zero @@ -1160,7
> +1163,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct
> net_device *dev,
>  				vf_tx_rate.vf =
>  				vf_spoofchk.vf =
>  				vf_linkstate.vf =
> -				vf_rss_query_en.vf = ivi.vf;
> +				vf_rss_query_en.vf =
> +				vf_trust.vf = ivi.vf;
> 
>  			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
>  			vf_vlan.vlan = ivi.vlan;
> @@ -1171,6 +1175,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb,
> struct net_device *dev,
>  			vf_spoofchk.setting = ivi.spoofchk;
>  			vf_linkstate.link_state = ivi.linkstate;
>  			vf_rss_query_en.setting = ivi.rss_query_en;
> +			vf_trust.setting = ivi.trusted;
>  			vf = nla_nest_start(skb, IFLA_VF_INFO);
>  			if (!vf) {
>  				nla_nest_cancel(skb, vfinfo);
> @@ -1524,6 +1529,16 @@ static int do_setvfinfo(struct net_device *dev,
> struct nlattr *attr)
>  							    ivrssq_en->setting);
>  			break;
>  		}
> +		case IFLA_VF_TRUST: {
> +			struct ifla_vf_trust *ivt;
> +
> +			ivt = nla_data(vf);
> +			err = -EOPNOTSUPP;
> +			if (ops->ndo_set_vf_trust)
> +				err = ops->ndo_set_vf_trust(dev, ivt->vf,
> +							    ivt->setting);
> +			break;
> +		}
>  		default:
>  			err = -EINVAL;
>  			break;
> --
> 1.8.3.1
> 
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
