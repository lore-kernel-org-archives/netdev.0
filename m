From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: |PATCH net-next] net: treewide use of RCU_INIT_POINTER
Date: Mon, 28 Nov 2011 17:44:01 -0800
Message-ID: <20111129014401.GT2346@linux.vnet.ibm.com>
References: <1322068172.17693.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:46776 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900Ab1K2Bpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 20:45:42 -0500
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 28 Nov 2011 20:45:39 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAT1i3Ed255362
	for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 20:44:24 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAT1i3fP022821
	for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 20:44:03 -0500
Content-Disposition: inline
In-Reply-To: <1322068172.17693.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 06:09:32PM +0100, Eric Dumazet wrote:
> rcu_assign_pointer(ptr, NULL) can be safely replaced by
> RCU_INIT_POINTER(ptr, NULL)
> 
> (old rcu_assign_pointer() macro was testing the NULL value and could
> omit the smp_wmb(), but this had to be removed because of compiler
> warnings)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This was probably the one lost in the USA Thanksgiving turkey, but...

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  drivers/net/ethernet/broadcom/bnx2.c               |    2 -
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    2 -
>  drivers/net/ethernet/broadcom/cnic.c               |    6 ++---
>  drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |    4 +--
>  drivers/net/macvtap.c                              |    8 +++----
>  drivers/net/ppp/pptp.c                             |    2 -
>  drivers/net/team/team_mode_activebackup.c          |    2 -
>  drivers/net/wireless/ath/carl9170/main.c           |   12 +++++------
>  net/core/netprio_cgroup.c                          |    4 +--
>  9 files changed, 21 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 83d8cef..d573169 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -409,7 +409,7 @@ static int bnx2_unregister_cnic(struct net_device *dev)
>  	mutex_lock(&bp->cnic_lock);
>  	cp->drv_state = 0;
>  	bnapi->cnic_present = 0;
> -	rcu_assign_pointer(bp->cnic_ops, NULL);
> +	RCU_INIT_POINTER(bp->cnic_ops, NULL);
>  	mutex_unlock(&bp->cnic_lock);
>  	synchronize_rcu();
>  	return 0;
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 83481e2..0cdbb70 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -11587,7 +11587,7 @@ static int bnx2x_unregister_cnic(struct net_device *dev)
> 
>  	mutex_lock(&bp->cnic_mutex);
>  	cp->drv_state = 0;
> -	rcu_assign_pointer(bp->cnic_ops, NULL);
> +	RCU_INIT_POINTER(bp->cnic_ops, NULL);
>  	mutex_unlock(&bp->cnic_mutex);
>  	synchronize_rcu();
>  	kfree(bp->cnic_kwq);
> diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
> index 099f41d..b336e55 100644
> --- a/drivers/net/ethernet/broadcom/cnic.c
> +++ b/drivers/net/ethernet/broadcom/cnic.c
> @@ -506,7 +506,7 @@ int cnic_unregister_driver(int ulp_type)
>  	}
>  	read_unlock(&cnic_dev_lock);
> 
> -	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], NULL);
> +	RCU_INIT_POINTER(cnic_ulp_tbl[ulp_type], NULL);
> 
>  	mutex_unlock(&cnic_lock);
>  	synchronize_rcu();
> @@ -579,7 +579,7 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
>  	}
>  	mutex_lock(&cnic_lock);
>  	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
> -		rcu_assign_pointer(cp->ulp_ops[ulp_type], NULL);
> +		RCU_INIT_POINTER(cp->ulp_ops[ulp_type], NULL);
>  		cnic_put(dev);
>  	} else {
>  		pr_err("%s: device not registered to this ulp type %d\n",
> @@ -5134,7 +5134,7 @@ static void cnic_stop_hw(struct cnic_dev *dev)
>  		}
>  		cnic_shutdown_rings(dev);
>  		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
> -		rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], NULL);
> +		RCU_INIT_POINTER(cp->ulp_ops[CNIC_ULP_L4], NULL);
>  		synchronize_rcu();
>  		cnic_cm_shutdown(dev);
>  		cp->stop_hw(dev);
> diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> index 90ff131..7f7882d 100644
> --- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> +++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> @@ -1301,7 +1301,7 @@ int cxgb3_offload_activate(struct adapter *adapter)
> 
>  out_free_l2t:
>  	t3_free_l2t(L2DATA(dev));
> -	rcu_assign_pointer(dev->l2opt, NULL);
> +	RCU_INIT_POINTER(dev->l2opt, NULL);
>  out_free:
>  	kfree(t);
>  	return err;
> @@ -1329,7 +1329,7 @@ void cxgb3_offload_deactivate(struct adapter *adapter)
>  	rcu_read_lock();
>  	d = L2DATA(tdev);
>  	rcu_read_unlock();
> -	rcu_assign_pointer(tdev->l2opt, NULL);
> +	RCU_INIT_POINTER(tdev->l2opt, NULL);
>  	call_rcu(&d->rcu_head, clean_l2_data);
>  	if (t->nofail_skb)
>  		kfree_skb(t->nofail_skb);
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 1b7082d..7c88d13 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -145,8 +145,8 @@ static void macvtap_put_queue(struct macvtap_queue *q)
>  	if (vlan) {
>  		int index = get_slot(vlan, q);
> 
> -		rcu_assign_pointer(vlan->taps[index], NULL);
> -		rcu_assign_pointer(q->vlan, NULL);
> +		RCU_INIT_POINTER(vlan->taps[index], NULL);
> +		RCU_INIT_POINTER(q->vlan, NULL);
>  		sock_put(&q->sk);
>  		--vlan->numvtaps;
>  	}
> @@ -223,8 +223,8 @@ static void macvtap_del_queues(struct net_device *dev)
>  					      lockdep_is_held(&macvtap_lock));
>  		if (q) {
>  			qlist[j++] = q;
> -			rcu_assign_pointer(vlan->taps[i], NULL);
> -			rcu_assign_pointer(q->vlan, NULL);
> +			RCU_INIT_POINTER(vlan->taps[i], NULL);
> +			RCU_INIT_POINTER(q->vlan, NULL);
>  			vlan->numvtaps--;
>  		}
>  	}
> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index 89f829f..ede899c 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -162,7 +162,7 @@ static void del_chan(struct pppox_sock *sock)
>  {
>  	spin_lock(&chan_lock);
>  	clear_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
> -	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
> +	RCU_INIT_POINTER(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
>  	spin_unlock(&chan_lock);
>  	synchronize_rcu();
>  }
> diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
> index b344275..f4d960e 100644
> --- a/drivers/net/team/team_mode_activebackup.c
> +++ b/drivers/net/team/team_mode_activebackup.c
> @@ -56,7 +56,7 @@ drop:
>  static void ab_port_leave(struct team *team, struct team_port *port)
>  {
>  	if (ab_priv(team)->active_port == port)
> -		rcu_assign_pointer(ab_priv(team)->active_port, NULL);
> +		RCU_INIT_POINTER(ab_priv(team)->active_port, NULL);
>  }
> 
>  static int ab_active_port_get(struct team *team, void *arg)
> diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
> index f06e069..5518592 100644
> --- a/drivers/net/wireless/ath/carl9170/main.c
> +++ b/drivers/net/wireless/ath/carl9170/main.c
> @@ -446,7 +446,7 @@ static void carl9170_op_stop(struct ieee80211_hw *hw)
> 
>  	mutex_lock(&ar->mutex);
>  	if (IS_ACCEPTING_CMD(ar)) {
> -		rcu_assign_pointer(ar->beacon_iter, NULL);
> +		RCU_INIT_POINTER(ar->beacon_iter, NULL);
> 
>  		carl9170_led_set_state(ar, 0);
> 
> @@ -678,7 +678,7 @@ unlock:
>  		vif_priv->active = false;
>  		bitmap_release_region(&ar->vif_bitmap, vif_id, 0);
>  		ar->vifs--;
> -		rcu_assign_pointer(ar->vif_priv[vif_id].vif, NULL);
> +		RCU_INIT_POINTER(ar->vif_priv[vif_id].vif, NULL);
>  		list_del_rcu(&vif_priv->list);
>  		mutex_unlock(&ar->mutex);
>  		synchronize_rcu();
> @@ -716,7 +716,7 @@ static void carl9170_op_remove_interface(struct ieee80211_hw *hw,
>  	WARN_ON(vif_priv->enable_beacon);
>  	vif_priv->enable_beacon = false;
>  	list_del_rcu(&vif_priv->list);
> -	rcu_assign_pointer(ar->vif_priv[id].vif, NULL);
> +	RCU_INIT_POINTER(ar->vif_priv[id].vif, NULL);
> 
>  	if (vif == main_vif) {
>  		rcu_read_unlock();
> @@ -1258,7 +1258,7 @@ static int carl9170_op_sta_add(struct ieee80211_hw *hw,
>  		}
> 
>  		for (i = 0; i < CARL9170_NUM_TID; i++)
> -			rcu_assign_pointer(sta_info->agg[i], NULL);
> +			RCU_INIT_POINTER(sta_info->agg[i], NULL);
> 
>  		sta_info->ampdu_max_len = 1 << (3 + sta->ht_cap.ampdu_factor);
>  		sta_info->ht_sta = true;
> @@ -1285,7 +1285,7 @@ static int carl9170_op_sta_remove(struct ieee80211_hw *hw,
>  			struct carl9170_sta_tid *tid_info;
> 
>  			tid_info = rcu_dereference(sta_info->agg[i]);
> -			rcu_assign_pointer(sta_info->agg[i], NULL);
> +			RCU_INIT_POINTER(sta_info->agg[i], NULL);
> 
>  			if (!tid_info)
>  				continue;
> @@ -1398,7 +1398,7 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
>  			spin_unlock_bh(&ar->tx_ampdu_list_lock);
>  		}
> 
> -		rcu_assign_pointer(sta_info->agg[tid], NULL);
> +		RCU_INIT_POINTER(sta_info->agg[tid], NULL);
>  		rcu_read_unlock();
> 
>  		ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index 72ad0bc..3a9fd48 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -285,7 +285,7 @@ static int netprio_device_event(struct notifier_block *unused,
>  		break;
>  	case NETDEV_UNREGISTER:
>  		old = rtnl_dereference(dev->priomap);
> -		rcu_assign_pointer(dev->priomap, NULL);
> +		RCU_INIT_POINTER(dev->priomap, NULL);
>  		if (old)
>  			kfree_rcu(old, rcu);
>  		break;
> @@ -332,7 +332,7 @@ static void __exit exit_cgroup_netprio(void)
>  	rtnl_lock();
>  	for_each_netdev(&init_net, dev) {
>  		old = rtnl_dereference(dev->priomap);
> -		rcu_assign_pointer(dev->priomap, NULL);
> +		RCU_INIT_POINTER(dev->priomap, NULL);
>  		if (old)
>  			kfree_rcu(old, rcu);
>  	}
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
