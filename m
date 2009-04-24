From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: about latencies
Date: Fri, 24 Apr 2009 16:18:20 +0200
Message-ID: <49F1CA2C.4080905@cosmosbay.com>
References: <49F0E579.5030200@cosmosbay.com> <alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com> <49F0F49A.1050609@cosmosbay.com> <alpine.DEB.1.10.0904240958070.20479@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35098 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759342AbZDXOTP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 10:19:15 -0400
In-Reply-To: <alpine.DEB.1.10.0904240958070.20479@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Fri, 24 Apr 2009, Eric Dumazet wrote:
>=20
>>> you're running a latency sensitive test on a NOHZ kernel below, isn=
't that
>>> a bad idea?
>> I tried worst case to match (eventually) Christoph data.
>> I usually am not using NOHZ, but what about linux distros ?
>=20
> Why does NOHZ have an impact here? Timed wakeups can happen using
> high res timers after all and a timer interrupt should be generated i=
f the
> network layer needs it.

I am not able to answer why it has an impact, but it is not cheap.

Compare function trace I sent yesterday, compared to this one without N=
OHZ
This one is far less noisy...

          <idle>-0     [000] 27907.377687: finish_task_switch <-__sched=
ule
          <idle>-0     [000] 27907.377688: mwait_idle <-cpu_idle
          <idle>-0     [000] 27907.377735: do_IRQ <-common_interrupt
          <idle>-0     [000] 27907.377736: irq_enter <-do_IRQ
          <idle>-0     [000] 27907.377736: idle_cpu <-irq_enter
          <idle>-0     [000] 27907.377736: tick_check_idle <-irq_enter
          <idle>-0     [000] 27907.377736: tick_check_oneshot_broadcast=
 <-tick_check_idle
          <idle>-0     [000] 27907.377736: handle_irq <-do_IRQ
          <idle>-0     [000] 27907.377737: irq_to_desc <-handle_irq
          <idle>-0     [000] 27907.377737: handle_edge_irq <-handle_irq
          <idle>-0     [000] 27907.377737: _spin_lock <-handle_edge_irq
          <idle>-0     [000] 27907.377737: ack_apic_edge <-handle_edge_=
irq
          <idle>-0     [000] 27907.377737: irq_to_desc <-ack_apic_edge
          <idle>-0     [000] 27907.377738: irq_complete_move <-ack_apic=
_edge
          <idle>-0     [000] 27907.377738: move_native_irq <-ack_apic_e=
dge
          <idle>-0     [000] 27907.377738: irq_to_desc <-move_native_ir=
q
          <idle>-0     [000] 27907.377738: native_apic_mem_write <-ack_=
apic_edge
          <idle>-0     [000] 27907.377738: handle_IRQ_event <-handle_ed=
ge_irq
          <idle>-0     [000] 27907.377739: bnx2_msi <-handle_IRQ_event
          <idle>-0     [000] 27907.377739: __napi_schedule <-bnx2_msi
          <idle>-0     [000] 27907.377739: note_interrupt <-handle_edge=
_irq
          <idle>-0     [000] 27907.377739: _spin_lock <-handle_edge_irq
          <idle>-0     [000] 27907.377740: irq_exit <-do_IRQ
          <idle>-0     [000] 27907.377740: do_softirq <-irq_exit
          <idle>-0     [000] 27907.377740: __do_softirq <-do_softirq
          <idle>-0     [000] 27907.377740: net_rx_action <-__do_softirq
          <idle>-0     [000] 27907.377740: bnx2_poll <-net_rx_action
          <idle>-0     [000] 27907.377741: bnx2_poll_work <-bnx2_poll
          <idle>-0     [000] 27907.377741: __netdev_alloc_skb <-bnx2_po=
ll_work
          <idle>-0     [000] 27907.377741: __alloc_skb <-__netdev_alloc=
_skb
          <idle>-0     [000] 27907.377741: kmem_cache_alloc <-__alloc_s=
kb
          <idle>-0     [000] 27907.377742: __kmalloc_track_caller <-__a=
lloc_skb
          <idle>-0     [000] 27907.377742: get_slab <-__kmalloc_track_c=
aller
          <idle>-0     [000] 27907.377742: skb_put <-bnx2_poll_work
          <idle>-0     [000] 27907.377742: eth_type_trans <-bnx2_poll_w=
ork
          <idle>-0     [000] 27907.377743: skb_pull <-eth_type_trans
          <idle>-0     [000] 27907.377743: __vlan_hwaccel_rx <-bnx2_pol=
l_work
          <idle>-0     [000] 27907.377743: netif_receive_skb <-__vlan_h=
waccel_rx
          <idle>-0     [000] 27907.377743: vlan_hwaccel_do_receive <-ne=
tif_receive_skb
          <idle>-0     [000] 27907.377743: netif_nit_deliver <-vlan_hwa=
ccel_do_receive
          <idle>-0     [000] 27907.377744: ip_rcv <-netif_receive_skb
          <idle>-0     [000] 27907.377744: nf_hook_slow <-ip_rcv
          <idle>-0     [000] 27907.377744: nf_iterate <-nf_hook_slow
          <idle>-0     [000] 27907.377744: ip_rcv_finish <-ip_rcv
          <idle>-0     [000] 27907.377745: ip_route_input <-ip_rcv_fini=
sh
          <idle>-0     [000] 27907.377745: ip_local_deliver <-ip_rcv_fi=
nish
          <idle>-0     [000] 27907.377745: nf_hook_slow <-ip_local_deli=
ver
          <idle>-0     [000] 27907.377745: nf_iterate <-nf_hook_slow
          <idle>-0     [000] 27907.377745: ipt_local_in_hook <-nf_itera=
te
          <idle>-0     [000] 27907.377746: ipt_do_table <-ipt_local_in_=
hook
          <idle>-0     [000] 27907.377746: local_bh_disable <-ipt_do_ta=
ble
          <idle>-0     [000] 27907.377746: _read_lock <-ipt_do_table
          <idle>-0     [000] 27907.377746: _read_unlock_bh <-ipt_do_tab=
le
          <idle>-0     [000] 27907.377747: local_bh_enable_ip <-_read_u=
nlock_bh
          <idle>-0     [000] 27907.377747: ip_local_deliver_finish <-ip=
_local_deliver
          <idle>-0     [000] 27907.377747: raw_local_deliver <-ip_local=
_deliver_finish
          <idle>-0     [000] 27907.377747: udp_rcv <-ip_local_deliver_f=
inish
          <idle>-0     [000] 27907.377748: __udp4_lib_rcv <-udp_rcv
          <idle>-0     [000] 27907.377748: __udp4_lib_lookup <-__udp4_l=
ib_rcv
          <idle>-0     [000] 27907.377748: udp_queue_rcv_skb <-__udp4_l=
ib_rcv
          <idle>-0     [000] 27907.377748: _spin_lock <-udp_queue_rcv_s=
kb
          <idle>-0     [000] 27907.377748: __udp_queue_rcv_skb <-udp_qu=
eue_rcv_skb
          <idle>-0     [000] 27907.377749: sock_queue_rcv_skb <-__udp_q=
ueue_rcv_skb
          <idle>-0     [000] 27907.377749: sk_filter <-sock_queue_rcv_s=
kb
          <idle>-0     [000] 27907.377749: local_bh_disable <-sk_filter
          <idle>-0     [000] 27907.377749: local_bh_enable <-sk_filter
          <idle>-0     [000] 27907.377749: skb_queue_tail <-sock_queue_=
rcv_skb
          <idle>-0     [000] 27907.377750: _spin_lock_irqsave <-skb_que=
ue_tail
          <idle>-0     [000] 27907.377750: _spin_unlock_irqrestore <-sk=
b_queue_tail
          <idle>-0     [000] 27907.377750: sock_def_readable <-sock_que=
ue_rcv_skb
          <idle>-0     [000] 27907.377750: _read_lock <-sock_def_readab=
le
          <idle>-0     [000] 27907.377750: __wake_up_sync_key <-sock_de=
f_readable
          <idle>-0     [000] 27907.377751: _spin_lock_irqsave <-__wake_=
up_sync_key
          <idle>-0     [000] 27907.377751: __wake_up_common <-__wake_up=
_sync_key
          <idle>-0     [000] 27907.377751: autoremove_wake_function <-_=
_wake_up_common
          <idle>-0     [000] 27907.377751: default_wake_function <-auto=
remove_wake_function
          <idle>-0     [000] 27907.377751: try_to_wake_up <-default_wak=
e_function
          <idle>-0     [000] 27907.377752: task_rq_lock <-try_to_wake_u=
p
          <idle>-0     [000] 27907.377752: _spin_lock <-task_rq_lock
          <idle>-0     [000] 27907.377752: select_task_rq_fair <-try_to=
_wake_up
          <idle>-0     [000] 27907.377752: activate_task <-try_to_wake_=
up
          <idle>-0     [000] 27907.377753: enqueue_task <-activate_task
          <idle>-0     [000] 27907.377753: enqueue_task_fair <-enqueue_=
task
          <idle>-0     [000] 27907.377753: update_curr <-enqueue_task_f=
air
          <idle>-0     [000] 27907.377753: place_entity <-enqueue_task_=
fair
          <idle>-0     [000] 27907.377753: __enqueue_entity <-enqueue_t=
ask_fair
          <idle>-0     [000] 27907.377754: hrtick_update <-enqueue_task=
_fair
          <idle>-0     [000] 27907.377754: check_preempt_curr_idle <-tr=
y_to_wake_up
          <idle>-0     [000] 27907.377754: resched_task <-check_preempt=
_curr_idle
          <idle>-0     [000] 27907.377754: _spin_unlock_irqrestore <-tr=
y_to_wake_up
          <idle>-0     [000] 27907.377755: _spin_unlock_irqrestore <-__=
wake_up_sync_key
          <idle>-0     [000] 27907.377756: napi_complete <-bnx2_poll
          <idle>-0     [000] 27907.377756: napi_gro_flush <-napi_comple=
te
          <idle>-0     [000] 27907.377756: __napi_complete <-napi_compl=
ete
          <idle>-0     [000] 27907.377756: rcu_bh_qsctr_inc <-__do_soft=
irq
          <idle>-0     [000] 27907.377757: _local_bh_enable <-__do_soft=
irq
          <idle>-0     [000] 27907.377757: schedule <-cpu_idle
          <idle>-0     [000] 27907.377757: __schedule <-schedule
          <idle>-0     [000] 27907.377757: rcu_qsctr_inc <-__schedule
          <idle>-0     [000] 27907.377758: _spin_lock_irq <-__schedule
          <idle>-0     [000] 27907.377758: put_prev_task_idle <-__sched=
ule
          <idle>-0     [000] 27907.377758: pick_next_task_fair <-__sche=
dule
          <idle>-0     [000] 27907.377758: __dequeue_entity <-pick_next=
_task_fair
         udpping-12642 [000] 27907.377759: finish_task_switch <-__sched=
ule
         udpping-12642 [000] 27907.377759: finish_wait <-__skb_recv_dat=
agram
         udpping-12642 [000] 27907.377759: _spin_lock_irqsave <-__skb_r=
ecv_datagram
         udpping-12642 [000] 27907.377760: _spin_unlock_irqrestore <-__=
skb_recv_datagram
         udpping-12642 [000] 27907.377760: skb_copy_datagram_iovec <-ud=
p_recvmsg
         udpping-12642 [000] 27907.377760: memcpy_toiovec <-skb_copy_da=
tagram_iovec
         udpping-12642 [000] 27907.377760: copy_to_user <-memcpy_toiove=
c
         udpping-12642 [000] 27907.377761: lock_sock_nested <-udp_recvm=
sg
         udpping-12642 [000] 27907.377761: _spin_lock_bh <-lock_sock_ne=
sted
         udpping-12642 [000] 27907.377761: local_bh_disable <-_spin_loc=
k_bh
         udpping-12642 [000] 27907.377761: local_bh_enable <-lock_sock_=
nested
         udpping-12642 [000] 27907.377761: skb_free_datagram <-udp_recv=
msg
         udpping-12642 [000] 27907.377762: consume_skb <-skb_free_datag=
ram
         udpping-12642 [000] 27907.377762: __kfree_skb <-consume_skb
         udpping-12642 [000] 27907.377762: skb_release_head_state <-__k=
free_skb
         udpping-12642 [000] 27907.377762: dst_release <-skb_release_he=
ad_state
         udpping-12642 [000] 27907.377762: sock_rfree <-skb_release_hea=
d_state
         udpping-12642 [000] 27907.377763: skb_release_data <-__kfree_s=
kb
         udpping-12642 [000] 27907.377763: kfree <-skb_release_data
         udpping-12642 [000] 27907.377763: kmem_cache_free <-__kfree_sk=
b
         udpping-12642 [000] 27907.377763: release_sock <-udp_recvmsg
         udpping-12642 [000] 27907.377764: _spin_lock_bh <-release_sock
         udpping-12642 [000] 27907.377764: local_bh_disable <-_spin_loc=
k_bh
         udpping-12642 [000] 27907.377764: _spin_unlock_bh <-release_so=
ck
         udpping-12642 [000] 27907.377764: local_bh_enable_ip <-_spin_u=
nlock_bh
         udpping-12642 [000] 27907.377764: move_addr_to_user <-sys_recv=
from
         udpping-12642 [000] 27907.377765: copy_to_user <-move_addr_to_=
user
         udpping-12642 [000] 27907.377765: sys_socketcall <-sysenter_do=
_call
         udpping-12642 [000] 27907.377765: copy_from_user <-sys_socketc=
all
         udpping-12642 [000] 27907.377766: sys_sendto <-sys_socketcall
         udpping-12642 [000] 27907.377766: sockfd_lookup_light <-sys_se=
ndto
         udpping-12642 [000] 27907.377766: fget_light <-sockfd_lookup_l=
ight
         udpping-12642 [000] 27907.377766: move_addr_to_kernel <-sys_se=
ndto
         udpping-12642 [000] 27907.377766: copy_from_user <-move_addr_t=
o_kernel
         udpping-12642 [000] 27907.377767: sock_sendmsg <-sys_sendto
         udpping-12642 [000] 27907.377767: inet_sendmsg <-sock_sendmsg
         udpping-12642 [000] 27907.377767: udp_sendmsg <-inet_sendmsg
         udpping-12642 [000] 27907.377767: sock_tx_timestamp <-udp_send=
msg
         udpping-12642 [000] 27907.377768: ip_route_output_flow <-udp_s=
endmsg
         udpping-12642 [000] 27907.377768: __ip_route_output_key <-ip_r=
oute_output_flow
         udpping-12642 [000] 27907.377768: local_bh_disable <-__ip_rout=
e_output_key
         udpping-12642 [000] 27907.377768: local_bh_enable <-__ip_route=
_output_key
         udpping-12642 [000] 27907.377769: __xfrm_lookup <-ip_route_out=
put_flow
         udpping-12642 [000] 27907.377769: lock_sock_nested <-udp_sendm=
sg
         udpping-12642 [000] 27907.377769: _spin_lock_bh <-lock_sock_ne=
sted
         udpping-12642 [000] 27907.377769: local_bh_disable <-_spin_loc=
k_bh
         udpping-12642 [000] 27907.377769: local_bh_enable <-lock_sock_=
nested
         udpping-12642 [000] 27907.377770: ip_append_data <-udp_sendmsg
         udpping-12642 [000] 27907.377770: sock_alloc_send_skb <-ip_app=
end_data
         udpping-12642 [000] 27907.377770: sock_alloc_send_pskb <-sock_=
alloc_send_skb
         udpping-12642 [000] 27907.377770: __alloc_skb <-sock_alloc_sen=
d_pskb
         udpping-12642 [000] 27907.377771: kmem_cache_alloc <-__alloc_s=
kb
         udpping-12642 [000] 27907.377771: __kmalloc_track_caller <-__a=
lloc_skb
         udpping-12642 [000] 27907.377771: get_slab <-__kmalloc_track_c=
aller
         udpping-12642 [000] 27907.377771: skb_put <-ip_append_data
         udpping-12642 [000] 27907.377772: ip_generic_getfrag <-ip_appe=
nd_data
         udpping-12642 [000] 27907.377772: csum_partial_copy_fromiovece=
nd <-ip_generic_getfrag
         udpping-12642 [000] 27907.377772: udp_push_pending_frames <-ud=
p_sendmsg
         udpping-12642 [000] 27907.377772: ip_push_pending_frames <-udp=
_push_pending_frames
         udpping-12642 [000] 27907.377773: ip_local_out <-ip_push_pendi=
ng_frames
         udpping-12642 [000] 27907.377773: __ip_local_out <-ip_local_ou=
t
         udpping-12642 [000] 27907.377773: nf_hook_slow <-__ip_local_ou=
t
         udpping-12642 [000] 27907.377773: nf_iterate <-nf_hook_slow
         udpping-12642 [000] 27907.377773: ipt_local_out_hook <-nf_iter=
ate
         udpping-12642 [000] 27907.377774: ipt_do_table <-ipt_local_out=
_hook
         udpping-12642 [000] 27907.377774: local_bh_disable <-ipt_do_ta=
ble
         udpping-12642 [000] 27907.377774: _read_lock <-ipt_do_table
         udpping-12642 [000] 27907.377774: _read_unlock_bh <-ipt_do_tab=
le
         udpping-12642 [000] 27907.377775: local_bh_enable_ip <-_read_u=
nlock_bh
         udpping-12642 [000] 27907.377775: ip_output <-ip_local_out
         udpping-12642 [000] 27907.377775: nf_hook_slow <-ip_output
         udpping-12642 [000] 27907.377775: nf_iterate <-nf_hook_slow
         udpping-12642 [000] 27907.377775: ip_finish_output <-ip_output
         udpping-12642 [000] 27907.377776: skb_push <-ip_finish_output
         udpping-12642 [000] 27907.377776: dev_queue_xmit <-ip_finish_o=
utput
         udpping-12642 [000] 27907.377776: local_bh_disable <-dev_queue=
_xmit
         udpping-12642 [000] 27907.377776: _spin_lock <-dev_queue_xmit
         udpping-12642 [000] 27907.377777: pfifo_fast_enqueue <-dev_que=
ue_xmit
         udpping-12642 [000] 27907.377777: __qdisc_run <-dev_queue_xmit
         udpping-12642 [000] 27907.377777: pfifo_fast_dequeue <-__qdisc=
_run
         udpping-12642 [000] 27907.377777: _spin_lock <-__qdisc_run
         udpping-12642 [000] 27907.377777: dev_hard_start_xmit <-__qdis=
c_run
         udpping-12642 [000] 27907.377778: vlan_dev_hwaccel_hard_start_=
xmit <-dev_hard_start_xmit
         udpping-12642 [000] 27907.377778: dev_queue_xmit <-vlan_dev_hw=
accel_hard_start_xmit
         udpping-12642 [000] 27907.377778: local_bh_disable <-dev_queue=
_xmit
         udpping-12642 [000] 27907.377778: dev_hard_start_xmit <-dev_qu=
eue_xmit
         udpping-12642 [000] 27907.377778: bond_start_xmit <-dev_hard_s=
tart_xmit
         udpping-12642 [000] 27907.377779: _read_lock <-bond_start_xmit
         udpping-12642 [000] 27907.377779: _read_lock <-bond_start_xmit
         udpping-12642 [000] 27907.377779: bond_dev_queue_xmit <-bond_s=
tart_xmit
         udpping-12642 [000] 27907.377779: dev_queue_xmit <-bond_dev_qu=
eue_xmit
         udpping-12642 [000] 27907.377780: local_bh_disable <-dev_queue=
_xmit
         udpping-12642 [000] 27907.377780: _spin_lock <-dev_queue_xmit
         udpping-12642 [000] 27907.377780: pfifo_fast_enqueue <-dev_que=
ue_xmit
         udpping-12642 [000] 27907.377780: __qdisc_run <-dev_queue_xmit
         udpping-12642 [000] 27907.377781: pfifo_fast_dequeue <-__qdisc=
_run
         udpping-12642 [000] 27907.377781: _spin_lock <-__qdisc_run
         udpping-12642 [000] 27907.377781: dev_hard_start_xmit <-__qdis=
c_run
         udpping-12642 [000] 27907.377782: bnx2_start_xmit <-dev_hard_s=
tart_xmit
         udpping-12642 [000] 27907.377782: skb_dma_map <-bnx2_start_xmi=
t
         udpping-12642 [000] 27907.377782: nommu_map_page <-skb_dma_map
         udpping-12642 [000] 27907.377782: dst_release <-bnx2_start_xmi=
t
         udpping-12642 [000] 27907.377782: sock_wfree <-bnx2_start_xmit
         udpping-12642 [000] 27907.377783: sock_def_write_space <-sock_=
wfree
         udpping-12642 [000] 27907.377783: _read_lock <-sock_def_write_=
space
         udpping-12642 [000] 27907.377783: _spin_lock <-__qdisc_run
         udpping-12642 [000] 27907.377784: local_bh_enable <-dev_queue_=
xmit
         udpping-12642 [000] 27907.377784: local_bh_enable <-dev_queue_=
xmit
         udpping-12642 [000] 27907.377784: _spin_lock <-__qdisc_run
         udpping-12642 [000] 27907.377784: local_bh_enable <-dev_queue_=
xmit
         udpping-12642 [000] 27907.377785: ip_cork_release <-ip_push_pe=
nding_frames
         udpping-12642 [000] 27907.377785: kfree <-ip_cork_release
         udpping-12642 [000] 27907.377785: dst_release <-ip_cork_releas=
e
         udpping-12642 [000] 27907.377785: release_sock <-udp_sendmsg
         udpping-12642 [000] 27907.377786: _spin_lock_bh <-release_sock
         udpping-12642 [000] 27907.377786: local_bh_disable <-_spin_loc=
k_bh
         udpping-12642 [000] 27907.377786: _spin_unlock_bh <-release_so=
ck
         udpping-12642 [000] 27907.377786: local_bh_enable_ip <-_spin_u=
nlock_bh
         udpping-12642 [000] 27907.377787: sys_socketcall <-sysenter_do=
_call
         udpping-12642 [000] 27907.377787: copy_from_user <-sys_socketc=
all
         udpping-12642 [000] 27907.377787: sys_recvfrom <-sys_socketcal=
l
         udpping-12642 [000] 27907.377787: sockfd_lookup_light <-sys_re=
cvfrom
         udpping-12642 [000] 27907.377788: fget_light <-sockfd_lookup_l=
ight
         udpping-12642 [000] 27907.377788: sock_recvmsg <-sys_recvfrom
         udpping-12642 [000] 27907.377788: sock_common_recvmsg <-sock_r=
ecvmsg
         udpping-12642 [000] 27907.377788: udp_recvmsg <-sock_common_re=
cvmsg
         udpping-12642 [000] 27907.377789: __skb_recv_datagram <-udp_re=
cvmsg
         udpping-12642 [000] 27907.377789: _spin_lock_irqsave <-__skb_r=
ecv_datagram
         udpping-12642 [000] 27907.377789: _spin_unlock_irqrestore <-__=
skb_recv_datagram
         udpping-12642 [000] 27907.377789: prepare_to_wait_exclusive <-=
__skb_recv_datagram
         udpping-12642 [000] 27907.377789: _spin_lock_irqsave <-prepare=
_to_wait_exclusive
         udpping-12642 [000] 27907.377790: _spin_unlock_irqrestore <-pr=
epare_to_wait_exclusive
         udpping-12642 [000] 27907.377790: do_IRQ <-common_interrupt
         udpping-12642 [000] 27907.377790: irq_enter <-do_IRQ
         udpping-12642 [000] 27907.377790: idle_cpu <-irq_enter
         udpping-12642 [000] 27907.377791: handle_irq <-do_IRQ
         udpping-12642 [000] 27907.377791: irq_to_desc <-handle_irq
         udpping-12642 [000] 27907.377791: handle_edge_irq <-handle_irq
         udpping-12642 [000] 27907.377791: _spin_lock <-handle_edge_irq
         udpping-12642 [000] 27907.377792: ack_apic_edge <-handle_edge_=
irq
         udpping-12642 [000] 27907.377792: irq_to_desc <-ack_apic_edge
         udpping-12642 [000] 27907.377792: irq_complete_move <-ack_apic=
_edge
         udpping-12642 [000] 27907.377792: move_native_irq <-ack_apic_e=
dge
         udpping-12642 [000] 27907.377792: irq_to_desc <-move_native_ir=
q
         udpping-12642 [000] 27907.377792: native_apic_mem_write <-ack_=
apic_edge
         udpping-12642 [000] 27907.377793: handle_IRQ_event <-handle_ed=
ge_irq
         udpping-12642 [000] 27907.377793: bnx2_msi <-handle_IRQ_event
         udpping-12642 [000] 27907.377793: __napi_schedule <-bnx2_msi
         udpping-12642 [000] 27907.377793: note_interrupt <-handle_edge=
_irq
         udpping-12642 [000] 27907.377794: _spin_lock <-handle_edge_irq
         udpping-12642 [000] 27907.377794: irq_exit <-do_IRQ
         udpping-12642 [000] 27907.377794: do_softirq <-irq_exit
         udpping-12642 [000] 27907.377794: __do_softirq <-do_softirq
         udpping-12642 [000] 27907.377795: net_rx_action <-__do_softirq
         udpping-12642 [000] 27907.377795: bnx2_poll <-net_rx_action
         udpping-12642 [000] 27907.377795: bnx2_poll_work <-bnx2_poll
         udpping-12642 [000] 27907.377795: skb_dma_unmap <-bnx2_poll_wo=
rk
         udpping-12642 [000] 27907.377795: consume_skb <-bnx2_poll_work
         udpping-12642 [000] 27907.377796: __kfree_skb <-consume_skb
         udpping-12642 [000] 27907.377796: skb_release_head_state <-__k=
free_skb
         udpping-12642 [000] 27907.377796: dst_release <-skb_release_he=
ad_state
         udpping-12642 [000] 27907.377796: skb_release_data <-__kfree_s=
kb
         udpping-12642 [000] 27907.377797: kfree <-skb_release_data
         udpping-12642 [000] 27907.377797: kmem_cache_free <-__kfree_sk=
b
         udpping-12642 [000] 27907.377797: napi_complete <-bnx2_poll
         udpping-12642 [000] 27907.377797: napi_gro_flush <-napi_comple=
te
         udpping-12642 [000] 27907.377798: __napi_complete <-napi_compl=
ete
         udpping-12642 [000] 27907.377798: rcu_bh_qsctr_inc <-__do_soft=
irq
         udpping-12642 [000] 27907.377798: _local_bh_enable <-__do_soft=
irq
         udpping-12642 [000] 27907.377799: schedule_timeout <-__skb_rec=
v_datagram
         udpping-12642 [000] 27907.377799: schedule <-schedule_timeout
         udpping-12642 [000] 27907.377799: __schedule <-schedule
         udpping-12642 [000] 27907.377799: rcu_qsctr_inc <-__schedule
         udpping-12642 [000] 27907.377799: _spin_lock_irq <-__schedule
         udpping-12642 [000] 27907.377800: deactivate_task <-__schedule
         udpping-12642 [000] 27907.377800: dequeue_task <-deactivate_ta=
sk
         udpping-12642 [000] 27907.377800: dequeue_task_fair <-dequeue_=
task
         udpping-12642 [000] 27907.377800: update_curr <-dequeue_task_f=
air
         udpping-12642 [000] 27907.377801: hrtick_update <-dequeue_task=
_fair
         udpping-12642 [000] 27907.377801: msecs_to_jiffies <-__schedul=
e
         udpping-12642 [000] 27907.377801: msecs_to_jiffies <-__schedul=
e
         udpping-12642 [000] 27907.377801: put_prev_task_fair <-__sched=
ule
         udpping-12642 [000] 27907.377801: pick_next_task_fair <-__sche=
dule
         udpping-12642 [000] 27907.377802: pick_next_task_rt <-__schedu=
le
         udpping-12642 [000] 27907.377802: pick_next_task_fair <-__sche=
dule
         udpping-12642 [000] 27907.377802: pick_next_task_idle <-__sche=
dule
          <idle>-0     [000] 27907.377802: finish_task_switch <-__sched=
ule
          <idle>-0     [000] 27907.377803: mwait_idle <-cpu_idle
          <idle>-0     [000] 27907.377851: do_IRQ <-common_interrupt
          <idle>-0     [000] 27907.377851: irq_enter <-do_IRQ
          <idle>-0     [000] 27907.377851: idle_cpu <-irq_enter
          <idle>-0     [000] 27907.377851: tick_check_idle <-irq_enter
          <idle>-0     [000] 27907.377851: tick_check_oneshot_broadcast=
 <-tick_check_idle
          <idle>-0     [000] 27907.377852: handle_irq <-do_IRQ
          <idle>-0     [000] 27907.377852: irq_to_desc <-handle_irq
          <idle>-0     [000] 27907.377852: handle_edge_irq <-handle_irq
          <idle>-0     [000] 27907.377852: _spin_lock <-handle_edge_irq
          <idle>-0     [000] 27907.377852: ack_apic_edge <-handle_edge_=
irq
          <idle>-0     [000] 27907.377853: irq_to_desc <-ack_apic_edge
          <idle>-0     [000] 27907.377853: irq_complete_move <-ack_apic=
_edge
          <idle>-0     [000] 27907.377853: move_native_irq <-ack_apic_e=
dge
          <idle>-0     [000] 27907.377853: irq_to_desc <-move_native_ir=
q
          <idle>-0     [000] 27907.377853: native_apic_mem_write <-ack_=
apic_edge
          <idle>-0     [000] 27907.377854: handle_IRQ_event <-handle_ed=
ge_irq
          <idle>-0     [000] 27907.377854: bnx2_msi <-handle_IRQ_event
          <idle>-0     [000] 27907.377854: __napi_schedule <-bnx2_msi
          <idle>-0     [000] 27907.377854: note_interrupt <-handle_edge=
_irq
          <idle>-0     [000] 27907.377855: _spin_lock <-handle_edge_irq
          <idle>-0     [000] 27907.377855: irq_exit <-do_IRQ
          <idle>-0     [000] 27907.377855: do_softirq <-irq_exit
          <idle>-0     [000] 27907.377855: __do_softirq <-do_softirq
          <idle>-0     [000] 27907.377856: net_rx_action <-__do_softirq
          <idle>-0     [000] 27907.377856: bnx2_poll <-net_rx_action
          <idle>-0     [000] 27907.377856: bnx2_poll_work <-bnx2_poll
          <idle>-0     [000] 27907.377856: __netdev_alloc_skb <-bnx2_po=
ll_work
          <idle>-0     [000] 27907.377856: __alloc_skb <-__netdev_alloc=
_skb
          <idle>-0     [000] 27907.377857: kmem_cache_alloc <-__alloc_s=
kb
          <idle>-0     [000] 27907.377857: __kmalloc_track_caller <-__a=
lloc_skb
          <idle>-0     [000] 27907.377857: get_slab <-__kmalloc_track_c=
aller
          <idle>-0     [000] 27907.377857: skb_put <-bnx2_poll_work
          <idle>-0     [000] 27907.377858: eth_type_trans <-bnx2_poll_w=
ork
          <idle>-0     [000] 27907.377858: skb_pull <-eth_type_trans
          <idle>-0     [000] 27907.377858: __vlan_hwaccel_rx <-bnx2_pol=
l_work
          <idle>-0     [000] 27907.377858: netif_receive_skb <-__vlan_h=
waccel_rx
          <idle>-0     [000] 27907.377859: vlan_hwaccel_do_receive <-ne=
tif_receive_skb
          <idle>-0     [000] 27907.377859: netif_nit_deliver <-vlan_hwa=
ccel_do_receive
          <idle>-0     [000] 27907.377859: ip_rcv <-netif_receive_skb
          <idle>-0     [000] 27907.377859: nf_hook_slow <-ip_rcv
          <idle>-0     [000] 27907.377859: nf_iterate <-nf_hook_slow
          <idle>-0     [000] 27907.377860: ip_rcv_finish <-ip_rcv
          <idle>-0     [000] 27907.377860: ip_route_input <-ip_rcv_fini=
sh
          <idle>-0     [000] 27907.377860: ip_local_deliver <-ip_rcv_fi=
nish
          <idle>-0     [000] 27907.377861: nf_hook_slow <-ip_local_deli=
ver
          <idle>-0     [000] 27907.377861: nf_iterate <-nf_hook_slow
          <idle>-0     [000] 27907.377861: ipt_local_in_hook <-nf_itera=
te
          <idle>-0     [000] 27907.377861: ipt_do_table <-ipt_local_in_=
hook
          <idle>-0     [000] 27907.377861: local_bh_disable <-ipt_do_ta=
ble
          <idle>-0     [000] 27907.377862: _read_lock <-ipt_do_table
          <idle>-0     [000] 27907.377862: _read_unlock_bh <-ipt_do_tab=
le
          <idle>-0     [000] 27907.377862: local_bh_enable_ip <-_read_u=
nlock_bh
          <idle>-0     [000] 27907.377862: ip_local_deliver_finish <-ip=
_local_deliver
          <idle>-0     [000] 27907.377863: raw_local_deliver <-ip_local=
_deliver_finish
          <idle>-0     [000] 27907.377863: udp_rcv <-ip_local_deliver_f=
inish
          <idle>-0     [000] 27907.377863: __udp4_lib_rcv <-udp_rcv
          <idle>-0     [000] 27907.377863: __udp4_lib_lookup <-__udp4_l=
ib_rcv
          <idle>-0     [000] 27907.377863: udp_queue_rcv_skb <-__udp4_l=
ib_rcv
          <idle>-0     [000] 27907.377864: _spin_lock <-udp_queue_rcv_s=
kb
          <idle>-0     [000] 27907.377864: __udp_queue_rcv_skb <-udp_qu=
eue_rcv_skb
          <idle>-0     [000] 27907.377864: sock_queue_rcv_skb <-__udp_q=
ueue_rcv_skb
          <idle>-0     [000] 27907.377864: sk_filter <-sock_queue_rcv_s=
kb
          <idle>-0     [000] 27907.377864: local_bh_disable <-sk_filter
          <idle>-0     [000] 27907.377865: local_bh_enable <-sk_filter
          <idle>-0     [000] 27907.377865: skb_queue_tail <-sock_queue_=
rcv_skb
          <idle>-0     [000] 27907.377865: smp_apic_timer_interrupt <-a=
pic_timer_interrupt
          <idle>-0     [000] 27907.377865: native_apic_mem_write <-smp_=
apic_timer_interrupt
          <idle>-0     [000] 27907.377866: irq_enter <-smp_apic_timer_i=
nterrupt
          <idle>-0     [000] 27907.377866: idle_cpu <-irq_enter
          <idle>-0     [000] 27907.377866: hrtimer_interrupt <-smp_apic=
_timer_interrupt
          <idle>-0     [000] 27907.377866: ktime_get <-hrtimer_interrup=
t
          <idle>-0     [000] 27907.377867: ktime_get_ts <-ktime_get
          <idle>-0     [000] 27907.377867: getnstimeofday <-ktime_get_t=
s
          <idle>-0     [000] 27907.377867: set_normalized_timespec <-kt=
ime_get_ts
          <idle>-0     [000] 27907.377867: _spin_lock <-hrtimer_interru=
pt
          <idle>-0     [000] 27907.377867: _spin_lock <-hrtimer_interru=
pt
          <idle>-0     [000] 27907.377868: __run_hrtimer <-hrtimer_inte=
rrupt
          <idle>-0     [000] 27907.377868: __remove_hrtimer <-__run_hrt=
imer
          <idle>-0     [000] 27907.377868: timer_stats_update_stats <-_=
_run_hrtimer
          <idle>-0     [000] 27907.377868: tick_sched_timer <-__run_hrt=
imer
          <idle>-0     [000] 27907.377869: ktime_get <-tick_sched_timer
          <idle>-0     [000] 27907.377869: ktime_get_ts <-ktime_get
          <idle>-0     [000] 27907.377869: getnstimeofday <-ktime_get_t=
s
          <idle>-0     [000] 27907.377869: set_normalized_timespec <-kt=
ime_get_ts
          <idle>-0     [000] 27907.377869: _spin_lock <-tick_sched_time=
r
          <idle>-0     [000] 27907.377870: do_timer <-tick_sched_timer
          <idle>-0     [000] 27907.377870: update_wall_time <-do_timer
          <idle>-0     [000] 27907.377871: clocksource_get_next <-updat=
e_wall_time
          <idle>-0     [000] 27907.377871: _spin_lock_irqsave <-clockso=
urce_get_next
          <idle>-0     [000] 27907.377871: _spin_unlock_irqrestore <-cl=
ocksource_get_next
          <idle>-0     [000] 27907.377872: update_process_times <-tick_=
sched_timer
          <idle>-0     [000] 27907.377872: account_process_tick <-updat=
e_process_times
          <idle>-0     [000] 27907.377872: account_idle_time <-account_=
process_tick
          <idle>-0     [000] 27907.377872: run_local_timers <-update_pr=
ocess_times
          <idle>-0     [000] 27907.377872: hrtimer_run_queues <-run_loc=
al_timers
          <idle>-0     [000] 27907.377873: raise_softirq <-run_local_ti=
mers
          <idle>-0     [000] 27907.377873: softlockup_tick <-run_local_=
timers
          <idle>-0     [000] 27907.377873: rcu_pending <-update_process=
_times
          <idle>-0     [000] 27907.377873: rcu_check_callbacks <-update=
_process_times
          <idle>-0     [000] 27907.377874: idle_cpu <-rcu_check_callbac=
ks
          <idle>-0     [000] 27907.377874: raise_softirq <-rcu_check_ca=
llbacks
          <idle>-0     [000] 27907.377874: printk_tick <-update_process=
_times
          <idle>-0     [000] 27907.377874: scheduler_tick <-update_proc=
ess_times
          <idle>-0     [000] 27907.377875: ktime_get <-sched_clock_tick
          <idle>-0     [000] 27907.377875: ktime_get_ts <-ktime_get
          <idle>-0     [000] 27907.377875: getnstimeofday <-ktime_get_t=
s
          <idle>-0     [000] 27907.377875: set_normalized_timespec <-kt=
ime_get_ts
          <idle>-0     [000] 27907.377875: _spin_lock <-scheduler_tick
          <idle>-0     [000] 27907.377876: task_tick_idle <-scheduler_t=
ick
          <idle>-0     [000] 27907.377876: run_posix_cpu_timers <-updat=
e_process_times
          <idle>-0     [000] 27907.377876: profile_tick <-tick_sched_ti=
mer
          <idle>-0     [000] 27907.377876: hrtimer_forward <-tick_sched=
_timer
          <idle>-0     [000] 27907.377877: ktime_add_safe <-hrtimer_for=
ward
          <idle>-0     [000] 27907.377877: ktime_add_safe <-hrtimer_for=
ward
          <idle>-0     [000] 27907.377877: _spin_lock <-__run_hrtimer
          <idle>-0     [000] 27907.377877: enqueue_hrtimer <-__run_hrti=
mer
          <idle>-0     [000] 27907.377878: tick_program_event <-hrtimer=
_interrupt
          <idle>-0     [000] 27907.377878: tick_dev_program_event <-tic=
k_program_event
          <idle>-0     [000] 27907.377878: ktime_get <-tick_dev_program=
_event
          <idle>-0     [000] 27907.377878: ktime_get_ts <-ktime_get
          <idle>-0     [000] 27907.377878: getnstimeofday <-ktime_get_t=
s
          <idle>-0     [000] 27907.377879: set_normalized_timespec <-kt=
ime_get_ts
          <idle>-0     [000] 27907.377879: clockevents_program_event <-=
tick_dev_program_event
          <idle>-0     [000] 27907.377879: lapic_next_event <-clockeven=
ts_program_event
          <idle>-0     [000] 27907.377879: native_apic_mem_write <-lapi=
c_next_event
          <idle>-0     [000] 27907.377880: irq_exit <-smp_apic_timer_in=
terrupt
          <idle>-0     [000] 27907.377880: _spin_lock_irqsave <-skb_que=
ue_tail
          <idle>-0     [000] 27907.377880: _spin_unlock_irqrestore <-sk=
b_queue_tail
          <idle>-0     [000] 27907.377880: sock_def_readable <-sock_que=
ue_rcv_skb
          <idle>-0     [000] 27907.377881: _read_lock <-sock_def_readab=
le
          <idle>-0     [000] 27907.377881: __wake_up_sync_key <-sock_de=
f_readable
          <idle>-0     [000] 27907.377881: _spin_lock_irqsave <-__wake_=
up_sync_key
          <idle>-0     [000] 27907.377881: __wake_up_common <-__wake_up=
_sync_key
          <idle>-0     [000] 27907.377881: autoremove_wake_function <-_=
_wake_up_common
          <idle>-0     [000] 27907.377882: default_wake_function <-auto=
remove_wake_function
          <idle>-0     [000] 27907.377882: try_to_wake_up <-default_wak=
e_function
          <idle>-0     [000] 27907.377882: task_rq_lock <-try_to_wake_u=
p
          <idle>-0     [000] 27907.377882: _spin_lock <-task_rq_lock
          <idle>-0     [000] 27907.377883: select_task_rq_fair <-try_to=
_wake_up
          <idle>-0     [000] 27907.377883: activate_task <-try_to_wake_=
up
          <idle>-0     [000] 27907.377883: enqueue_task <-activate_task
          <idle>-0     [000] 27907.377884: enqueue_task_fair <-enqueue_=
task
          <idle>-0     [000] 27907.377884: update_curr <-enqueue_task_f=
air
          <idle>-0     [000] 27907.377884: place_entity <-enqueue_task_=
fair
          <idle>-0     [000] 27907.377884: __enqueue_entity <-enqueue_t=
ask_fair
          <idle>-0     [000] 27907.377885: hrtick_update <-enqueue_task=
_fair
          <idle>-0     [000] 27907.377885: check_preempt_curr_idle <-tr=
y_to_wake_up
          <idle>-0     [000] 27907.377885: resched_task <-check_preempt=
_curr_idle
          <idle>-0     [000] 27907.377885: _spin_unlock_irqrestore <-tr=
y_to_wake_up
          <idle>-0     [000] 27907.377886: _spin_unlock_irqrestore <-__=
wake_up_sync_key
          <idle>-0     [000] 27907.377886: napi_complete <-bnx2_poll
          <idle>-0     [000] 27907.377886: napi_gro_flush <-napi_comple=
te
          <idle>-0     [000] 27907.377887: __napi_complete <-napi_compl=
ete
          <idle>-0     [000] 27907.377887: rcu_bh_qsctr_inc <-__do_soft=
irq
          <idle>-0     [000] 27907.377887: run_timer_softirq <-__do_sof=
tirq
          <idle>-0     [000] 27907.377887: hrtimer_run_pending <-run_ti=
mer_softirq
          <idle>-0     [000] 27907.377888: _spin_lock_irq <-run_timer_s=
oftirq
          <idle>-0     [000] 27907.377888: rcu_bh_qsctr_inc <-__do_soft=
irq
          <idle>-0     [000] 27907.377888: rcu_process_callbacks <-__do=
_softirq
          <idle>-0     [000] 27907.377888: __rcu_process_callbacks <-rc=
u_process_callbacks
          <idle>-0     [000] 27907.377889: cpu_quiet <-__rcu_process_ca=
llbacks
          <idle>-0     [000] 27907.377889: _spin_lock_irqsave <-cpu_qui=
et
          <idle>-0     [000] 27907.377889: cpu_quiet_msk <-cpu_quiet
          <idle>-0     [000] 27907.377889: _spin_unlock_irqrestore <-cp=
u_quiet_msk
          <idle>-0     [000] 27907.377890: __rcu_process_callbacks <-rc=
u_process_callbacks
          <idle>-0     [000] 27907.377890: force_quiescent_state <-__rc=
u_process_callbacks
          <idle>-0     [000] 27907.377890: rcu_bh_qsctr_inc <-__do_soft=
irq
          <idle>-0     [000] 27907.377890: _local_bh_enable <-__do_soft=
irq
          <idle>-0     [000] 27907.377891: schedule <-cpu_idle
          <idle>-0     [000] 27907.377891: __schedule <-schedule
          <idle>-0     [000] 27907.377891: rcu_qsctr_inc <-__schedule
          <idle>-0     [000] 27907.377891: _spin_lock_irq <-__schedule
          <idle>-0     [000] 27907.377892: put_prev_task_idle <-__sched=
ule
          <idle>-0     [000] 27907.377892: pick_next_task_fair <-__sche=
dule
          <idle>-0     [000] 27907.377892: __dequeue_entity <-pick_next=
_task_fair

