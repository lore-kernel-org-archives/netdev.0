From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/6] [net-next]net: sched: act_mirred: Extend redirect
 action to accept a traffic class
Date: Tue, 1 Aug 2017 06:22:16 -0400
Message-ID: <85d57ef2-1c9f-d0e6-a3e8-d65078485afb@mojatatu.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <150154785793.4135.15194023552358061083.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34308 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751778AbdHAKWS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:22:18 -0400
Received: by mail-it0-f65.google.com with SMTP id t78so1280405ita.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 03:22:18 -0700 (PDT)
In-Reply-To: <150154785793.4135.15194023552358061083.stgit@anamdev.jf.intel.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-31 08:37 PM, Amritha Nambiar wrote:
> The Mirred/redirect action is extended to forward to a traffic
> class on the device. The traffic class index needs to be
> provided in addition to the device's ifindex.
> 
> Example:
> # tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>    dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>    skip_sw indev eth0 action mirred ingress redirect dev eth0 tc 1
> 
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> ---
>   include/net/tc_act/tc_mirred.h        |    7 +++++++
>   include/uapi/linux/tc_act/tc_mirred.h |    5 +++++
>   net/sched/act_mirred.c                |   17 +++++++++++++++++
>   3 files changed, 29 insertions(+)
> 
> diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
> index 604bc31..60058c4 100644
> --- a/include/net/tc_act/tc_mirred.h
> +++ b/include/net/tc_act/tc_mirred.h
> @@ -9,6 +9,8 @@ struct tcf_mirred {
>   	int			tcfm_eaction;
>   	int			tcfm_ifindex;
>   	bool			tcfm_mac_header_xmit;
> +	u8			tcfm_tc;
> +	u32			flags;
>   	struct net_device __rcu	*tcfm_dev;
>   	struct list_head	tcfm_list;
>   };
> @@ -37,4 +39,9 @@ static inline int tcf_mirred_ifindex(const struct tc_action *a)
>   	return to_mirred(a)->tcfm_ifindex;
>   }
>   
> +static inline int tcf_mirred_tc(const struct tc_action *a)
> +{
> +	return to_mirred(a)->tcfm_tc;
> +}
> +
>   #endif /* __NET_TC_MIR_H */
> diff --git a/include/uapi/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
> index 3d7a2b3..8ff4d76 100644
> --- a/include/uapi/linux/tc_act/tc_mirred.h
> +++ b/include/uapi/linux/tc_act/tc_mirred.h
> @@ -9,6 +9,10 @@
>   #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
>   #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
>   #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
> +
> +#define MIRRED_F_TC_MAP		0x1
> +#define MIRRED_TC_MAP_MAX	0x10

Assuming this is the max number of queues?
Where does this upper bound come from? Is it a spec
or an intel thing? If spec - mentioning which
spec and section would be useful.

cheers,
jamal
