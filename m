From: Ying Xue <ying.xue@windriver.com>
Subject: Re: Fw: New Defects reported by Coverity Scan for Linux
Date: Wed, 4 Nov 2015 09:45:04 +0800
Message-ID: <56396320.5080605@windriver.com>
References: <20151103081812.6c55fbe5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unknown.windriver.com ([192.103.53.11]:51556 "EHLO
	mail5.wrs.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755317AbbKDCLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 21:11:43 -0500
In-Reply-To: <20151103081812.6c55fbe5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2015 12:18 AM, Stephen Hemminger wrote:
> The TIPC case is a missing check for memory allocation failure.
> 

Thanks for the report. I will fix it soon.

Regards,
Ying

> 
> Begin forwarded message:
> 
> Date: Mon, 02 Nov 2015 23:45:55 -0800
> From: scan-admin@coverity.com
> To: stephen@networkplumber.org
> Subject: New Defects reported by Coverity Scan for Linux
> 
> 
> 
> Hi,
> 
> Please find the latest report on new defect(s) introduced to Linux found with Coverity Scan.
> 
> 4 new defect(s) introduced to Linux found with Coverity Scan.
> 9 defect(s), reported by Coverity Scan earlier, were marked fixed in the recent build analyzed by Coverity Scan.
> 
> New defect(s) Reported-by: Coverity Scan
> Showing 4 of 4 defect(s)
> 
> 
> ** CID 1338065:  Error handling issues  (CHECKED_RETURN)
> /net/tipc/udp_media.c: 162 in tipc_udp_send_msg()
> 
> 
> ________________________________________________________________________________________________________
> *** CID 1338065:  Error handling issues  (CHECKED_RETURN)
> /net/tipc/udp_media.c: 162 in tipc_udp_send_msg()
> 156     	struct udp_media_addr *dst = (struct udp_media_addr *)&dest->value;
> 157     	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
> 158     	struct sk_buff *clone;
> 159     	struct rtable *rt;
> 160     
> 161     	if (skb_headroom(skb) < UDP_MIN_HEADROOM)
>>>>     CID 1338065:  Error handling issues  (CHECKED_RETURN)
>>>>     Calling "pskb_expand_head" without checking return value (as is done elsewhere 51 out of 56 times).
> 162     		pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
> 163     
> 164     	clone = skb_clone(skb, GFP_ATOMIC);
> 165     	skb_set_inner_protocol(clone, htons(ETH_P_TIPC));
> 166     	ub = rcu_dereference_rtnl(b->media_ptr);
> 167     	if (!ub) {
> 
> ** CID 1338066:  Null pointer dereferences  (FORWARD_NULL)
> /net/openvswitch/flow_netlink.c: 1379 in __ovs_nla_put_key()
> 
> 
> ________________________________________________________________________________________________________
> *** CID 1338066:  Null pointer dereferences  (FORWARD_NULL)
> /net/openvswitch/flow_netlink.c: 1379 in __ovs_nla_put_key()
> 1373     		goto nla_put_failure;
> 1374     
> 1375     	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
> 1376     		goto nla_put_failure;
> 1377     
> 1378     	if ((swkey->tun_key.u.ipv4.dst || is_mask)) {
>>>>     CID 1338066:  Null pointer dereferences  (FORWARD_NULL)
>>>>     Assigning: "opts" = "NULL".
> 1379     		const void *opts = NULL;
> 1380     
> 1381     		if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
> 1382     			opts = TUN_METADATA_OPTS(output, swkey->tun_opts_len);
> 1383     
> 1384     		if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
> 
> ** CID 1338067:  Integer handling issues  (OVERFLOW_BEFORE_WIDEN)
> /drivers/net/ethernet/cavium/thunder/nic_main.c: 407 in nic_config_cpi()
> 
> 
> ________________________________________________________________________________________________________
> *** CID 1338067:  Integer handling issues  (OVERFLOW_BEFORE_WIDEN)
> /drivers/net/ethernet/cavium/thunder/nic_main.c: 407 in nic_config_cpi()
> 401     			nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi << 3),
> 402     				      (vnic << 24) | (padd << 16) |
> 403     				      (rssi_base + rssi));
> 404     		} else {
> 405     			/* Set MPI_ALG to '0' to disable MCAM parsing */
> 406     			nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi << 3),
>>>>     CID 1338067:  Integer handling issues  (OVERFLOW_BEFORE_WIDEN)
>>>>     Potentially overflowing expression "padd << 16" with type "u32" (32 bits, unsigned) is evaluated using 32-bit arithmetic, and then used in a context that expects an expression of type "u64" (64 bits, unsigned).
> 407     				      (padd << 16));
> 408     			/* MPI index is same as CPI if MPI_ALG is not enabled */
> 409     			nic_reg_write(nic, NIC_PF_MPI_0_2047_CFG | (cpi << 3),
> 410     				      (vnic << 24) | (rssi_base + rssi));
> 411     		}
> 412     
> 
> ** CID 1338068:  Null pointer dereferences  (REVERSE_INULL)
> /include/net/dst_metadata.h: 69 in tun_dst_unclone()
> 
> 
> ________________________________________________________________________________________________________
> *** CID 1338068:  Null pointer dereferences  (REVERSE_INULL)
> /include/net/dst_metadata.h: 69 in tun_dst_unclone()
> 63     static inline struct metadata_dst *tun_dst_unclone(struct sk_buff *skb)
> 64     {
> 65     	struct metadata_dst *md_dst = skb_metadata_dst(skb);
> 66     	int md_size = md_dst->u.tun_info.options_len;
> 67     	struct metadata_dst *new_md;
> 68     
>>>>     CID 1338068:  Null pointer dereferences  (REVERSE_INULL)
>>>>     Null-checking "md_dst" suggests that it may be null, but it has already been dereferenced on all paths leading to the check.
> 69     	if (!md_dst)
> 70     		return ERR_PTR(-EINVAL);
> 71     
> 72     	new_md = metadata_dst_alloc(md_size, GFP_ATOMIC);
> 73     	if (!new_md)
> 74     		return ERR_PTR(-ENOMEM);
> 
> 
> ________________________________________________________________________________________________________
> To view the defects in Coverity Scan visit, https://scan.coverity.com/projects/linux?tab=overview
> 
> To manage Coverity Scan email notifications for "stephen@networkplumber.org", click https://scan.coverity.com/subscriptions/edit?email=stephen%40networkplumber.org&token=41b352b884ef3fc73426635eebc294c3
> 
> 
