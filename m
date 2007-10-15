From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: kernel BUG at net/core/dev.c:1383 skb_checksum_help:
 BUG_ON(offset > (int)skb->len)
Date: Mon, 15 Oct 2007 12:18:29 +0200
Message-ID: <20071015121829.15521102@inria.fr>
References: <20071006141506.785a6683@localhost.localdomain>
	<20071014192640.35065e73@inria.fr>
	<Pine.LNX.4.64.0710151251090.3767@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0710151311540.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:52531 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756805AbXJOKVS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 06:21:18 -0400
In-Reply-To: <Pine.LNX.4.64.0710151311540.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Mon, 15 Oct 2007 13:15:05 +0300 (EEST),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :
=20
> ...Never mind, noticed the fix later on.

Yes, but here is it anyway, in case you see something fishy.

(gdb) p *(struct tcp_sock *)skb->sk
$4 =3D {inet_conn =3D {icsk_inet =3D {sk =3D {__sk_common =3D {skc_fami=
ly =3D 2,=20
          skc_state =3D 1 '\001', skc_reuse =3D 1 '\001', skc_bound_dev=
_if =3D 0,=20
          skc_node =3D {next =3D 0x0, pprev =3D 0xc6179450}, skc_bind_n=
ode =3D {
            next =3D 0xf5227550, pprev =3D 0xeebd3110}, skc_refcnt =3D =
{
            counter =3D 4}, skc_hash =3D 710603402, skc_prot =3D 0xc03f=
8720,=20
          skc_net =3D 0xc048ad60}, sk_shutdown =3D 0 '\0', sk_no_check =
=3D 0 '\0',=20
        sk_userlocks =3D 0 '\0', sk_protocol =3D 6 '\006', sk_type =3D =
1,=20
        sk_rcvbuf =3D 87380, sk_lock =3D {slock =3D {raw_lock =3D {<No =
data fields>}},=20
          owned =3D 0, wq =3D {lock =3D {raw_lock =3D {<No data fields>=
}},=20
            task_list =3D {next =3D 0xf5180474, prev =3D 0xf5180474}}},=
=20
        sk_backlog =3D {head =3D 0x0, tail =3D 0x0}, sk_sleep =3D 0xf57=
70918,=20
        sk_dst_cache =3D 0xed3db300, sk_policy =3D {0x0, 0x0}, sk_dst_l=
ock =3D {
          raw_lock =3D {<No data fields>}}, sk_rmem_alloc =3D {counter =
=3D 63680},=20
        sk_wmem_alloc =3D {counter =3D 488}, sk_omem_alloc =3D {counter=
 =3D 0},=20
        sk_sndbuf =3D 76188, sk_receive_queue =3D {next =3D 0xf51804a4,=
=20
          prev =3D 0xf51804a4, qlen =3D 0, lock =3D {
            raw_lock =3D {<No data fields>}}}, sk_write_queue =3D {
          next =3D 0xe218dc00, prev =3D 0xf0fdba80, qlen =3D 25, lock =3D=
 {
            raw_lock =3D {<No data fields>}}}, sk_async_wait_queue =3D =
{
          next =3D 0x0, prev =3D 0x0, qlen =3D 0, lock =3D {
            raw_lock =3D {<No data fields>}}}, sk_wmem_queued =3D 33896=
,=20
        sk_forward_alloc =3D 4824, sk_allocation =3D 208, sk_route_caps=
 =3D 0,=20
        sk_gso_type =3D 1, sk_rcvlowat =3D 1, sk_flags =3D 17152, sk_li=
ngertime =3D 0,=20
        sk_error_queue =3D {next =3D 0xf51804e8, prev =3D 0xf51804e8, q=
len =3D 0,=20
          lock =3D {raw_lock =3D {<No data fields>}}},=20
        sk_prot_creator =3D 0xc03f8720, sk_callback_lock =3D {
          raw_lock =3D {<No data fields>}}, sk_err =3D 0, sk_err_soft =3D=
 0,=20
        sk_ack_backlog =3D 0, sk_max_ack_backlog =3D 50, sk_priority =3D=
 2,=20
        sk_peercred =3D {pid =3D 0, uid =3D 4294967295, gid =3D 4294967=
295},=20
        sk_rcvtimeo =3D 2147483647, sk_sndtimeo =3D 2147483647, sk_filt=
er =3D 0x0,=20
        sk_protinfo =3D 0x0, sk_timer =3D {entry =3D {next =3D 0x0,=20
            prev =3D 0xc04768e8}, expires =3D 2104092,=20
          function =3D 0xc02fa3b8 <tcp_keepalive_timer>, data =3D 41119=
91872,=20
          base =3D 0xc0476800}, sk_stamp =3D {tv64 =3D 3294967295},=20
        sk_socket =3D 0xf5770900, sk_user_data =3D 0x0, sk_sndmsg_page =
=3D 0x0,=20
        sk_send_head =3D 0xcc26cc00, sk_sndmsg_off =3D 0, sk_write_pend=
ing =3D 0,=20
        sk_security =3D 0x0, sk_state_change =3D 0xc02c2737 <sock_def_w=
akeup>,=20
        sk_data_ready =3D 0xc02c2f8c <sock_def_readable>,=20
        sk_write_space =3D 0xc02c6dc7 <sk_stream_write_space>,=20
        sk_error_report =3D 0xc02c2f22 <sock_def_error_report>,=20
        sk_backlog_rcv =3D 0xc02fbc3a <tcp_v4_do_rcv>,=20
        sk_destruct =3D 0xc0308062 <inet_sock_destruct>}, pinet6 =3D 0x=
0,=20
      daddr =3D 1743516497, rcv_saddr =3D 50374848, dport =3D 11768, nu=
m =3D 6881,=20
      saddr =3D 50374848, uc_ttl =3D -1, cmsg_flags =3D 0, opt =3D 0x0,=
 sport =3D 57626,=20
      id =3D 19592, tos =3D 8 '\b', mc_ttl =3D 47 '/', pmtudisc =3D 1 '=
\001',=20
      recverr =3D 0 '\0', is_icsk =3D 1 '\001', freebind =3D 0 '\0',=20
      hdrincl =3D 0 '\0', mc_loop =3D 1 '\001', mc_index =3D 3, mc_addr=
 =3D 0,=20
      mc_list =3D 0x0, cork =3D {flags =3D 0, fragsize =3D 0, opt =3D 0=
x0, rt =3D 0x0,=20
        length =3D 0, addr =3D 0, fl =3D {oif =3D 0, iif =3D 0, mark =3D=
 0, nl_u =3D {
            ip4_u =3D {daddr =3D 0, saddr =3D 0, tos =3D 0 '\0', scope =
=3D 0 '\0'},=20
            ip6_u =3D {daddr =3D {in6_u =3D {u6_addr8 =3D {0 '\0' <repe=
ats 16 times>},=20
                  u6_addr16 =3D {0, 0, 0, 0, 0, 0, 0, 0}, u6_addr32 =3D=
 {0, 0, 0,=20
                    0}}}, saddr =3D {in6_u =3D {u6_addr8 =3D {
                    0 '\0' <repeats 16 times>}, u6_addr16 =3D {0, 0, 0,=
 0, 0, 0,=20
                    0, 0}, u6_addr32 =3D {0, 0, 0, 0}}}, flowlabel =3D =
0}, dn_u =3D {
              daddr =3D 0, saddr =3D 0, scope =3D 0 '\0'}}, proto =3D 0=
 '\0',=20
          flags =3D 0 '\0', uli_u =3D {ports =3D {sport =3D 0, dport =3D=
 0}, icmpt =3D {
              type =3D 0 '\0', code =3D 0 '\0'}, dnports =3D {sport =3D=
 0, dport =3D 0},=20
            spi =3D 0, mht =3D {type =3D 0 '\0'}}, secid =3D 0}}},=20
    icsk_accept_queue =3D {rskq_accept_head =3D 0x0, rskq_accept_tail =3D=
 0x0,=20
      syn_wait_lock =3D {raw_lock =3D {<No data fields>}},=20
      rskq_defer_accept =3D 0 '\0', listen_opt =3D 0x0},=20
    icsk_bind_hash =3D 0xc639e820, icsk_timeout =3D 4955116,=20
    icsk_retransmit_timer =3D {entry =3D {next =3D 0xc04770e0, prev =3D=
 0xc03e3e50},=20
      expires =3D 4955116, function =3D 0xc02fa6fc <tcp_write_timer>,=20
      data =3D 4111991872, base =3D 0xc0476800}, icsk_delack_timer =3D =
{entry =3D {
        next =3D 0x0, prev =3D 0x200200}, expires =3D 4944512,=20
      function =3D 0xc02fa57a <tcp_delack_timer>, data =3D 4111991872,=20
      base =3D 0xc0476800}, icsk_rto =3D 5009, icsk_pmtu_cookie =3D 150=
0,=20
    icsk_ca_ops =3D 0xc03fa3e0, icsk_af_ops =3D 0xc03f86e0,=20
    icsk_sync_mss =3D 0xc02f6efd <tcp_sync_mss>, icsk_ca_state =3D 3 '\=
003',=20
    icsk_retransmits =3D 0 '\0', icsk_pending =3D 1 '\001', icsk_backof=
f =3D 0 '\0',=20
    icsk_syn_retries =3D 0 '\0', icsk_probes_out =3D 0 '\0', icsk_ext_h=
dr_len =3D 0,=20
    icsk_ack =3D {pending =3D 0 '\0', quick =3D 0 '\0', pingpong =3D 0 =
'\0',=20
      blocked =3D 0 '\0', ato =3D 40, timeout =3D 4944512, lrcvtime =3D=
 4944507,=20
      last_seg_size =3D 0, rcv_mss =3D 1402}, icsk_mtup =3D {enabled =3D=
 0,=20
      search_high =3D 1454, search_low =3D 564, probe_size =3D 0}, icsk=
_ca_priv =3D {
      6, 13, 13, 12, 4946610, 8, 0, 992, 0, 17, 13, 31, 0, 0, 0, 0}},=20
  tcp_header_len =3D 32, xmit_size_goal =3D 1374, pred_flags =3D 0,=20
  rcv_nxt =3D 3213349733, copied_seq =3D 3213349733, rcv_wup =3D 321334=
9733,=20
  snd_nxt =3D 4014280275, snd_una =3D 4014269059, snd_sml =3D 401427889=
3,=20
  rcv_tstamp =3D 4950107, lsndtime =3D 4950107, ucopy =3D {prequeue =3D=
 {
      next =3D 0xf51806ec, prev =3D 0xf51806ec, qlen =3D 0, lock =3D {
        raw_lock =3D {<No data fields>}}}, task =3D 0x0, iov =3D 0x0, m=
emory =3D 0,=20
    len =3D 0}, snd_wl1 =3D 3213368850, snd_wnd =3D 64512, max_window =3D=
 65535,=20
  mss_cache =3D 1402, window_clamp =3D 64087, rcv_ssthresh =3D 64087,=20
  frto_highmark =3D 0, reordering =3D 3 '\003', frto_counter =3D 0 '\0'=
,=20
  nonagle =3D 0 '\0', keepalive_probes =3D 0 '\0', srtt =3D 15439, mdev=
 =3D 3080,=20
  mdev_max =3D 3080, rttvar =3D 3080, rtt_seq =3D 4014273285, packets_o=
ut =3D 16,=20
  retrans_out =3D 0, rx_opt =3D {ts_recent_stamp =3D 1192377268,=20
    ts_recent =3D 1289741881, rcv_tsval =3D 1289741893, rcv_tsecr =3D 4=
946974,=20
    saw_tstamp =3D 1, tstamp_ok =3D 1, dsack =3D 0, wscale_ok =3D 1, sa=
ck_ok =3D 3,=20
    snd_wscale =3D 0, rcv_wscale =3D 7, eff_sacks =3D 3 '\003',=20
    num_sacks =3D 4 '\004', user_mss =3D 0, mss_clamp =3D 1414}, snd_ss=
thresh =3D 10,=20
  snd_cwnd =3D 1, snd_cwnd_cnt =3D 1, snd_cwnd_clamp =3D 4294967295,=20
  snd_cwnd_used =3D 0, snd_cwnd_stamp =3D 4950107, out_of_order_queue =3D=
 {
    next =3D 0xf7d18480, prev =3D 0xf68436c0, qlen =3D 20, lock =3D {
      raw_lock =3D {<No data fields>}}}, rcv_wnd =3D 63232,=20
  write_seq =3D 4014290666, pushed_seq =3D 4014290666, duplicate_sack =3D=
 {{
      start_seq =3D 3213316897, end_seq =3D 3213317373}}, selective_ack=
s =3D {{
      start_seq =3D 3213363849, end_seq =3D 3213368850}, {start_seq =3D=
 3213361222,=20
      end_seq =3D 3213362459}, {start_seq =3D 3213357313, end_seq =3D 3=
213359832}, {
      start_seq =3D 3213351135, end_seq =3D 3213357073}}, recv_sack_cac=
he =3D {{
      start_seq =3D 1945650415, end_seq =3D 1393444335}, {start_seq =3D=
 0,=20
      end_seq =3D 0}, {start_seq =3D 0, end_seq =3D 0}, {start_seq =3D =
0,=20
      end_seq =3D 0}}, highest_sack =3D 4014278893, lost_skb_hint =3D 0=
xf56d8480,=20
  scoreboard_skb_hint =3D 0x0, retransmit_skb_hint =3D 0xe218dc00,=20
  forward_skb_hint =3D 0x0, fastpath_skb_hint =3D 0x0, fastpath_cnt_hin=
t =3D 15,=20
  lost_cnt_hint =3D 13, retransmit_cnt_hint =3D 0, lost_retrans_low =3D=
 0,=20
  advmss =3D 1448, prior_ssthresh =3D 9, lost_out =3D 8, sacked_out =3D=
 8,=20
  fackets_out =3D 16, high_seq =3D 4014280275, retrans_stamp =3D 494697=
4,=20
  undo_marker =3D 4014267677, undo_retrans =3D 17, urg_seq =3D 0, urg_d=
ata =3D 0,=20
  urg_mode =3D 0 '\0', ecn_flags =3D 0 '\0', snd_up =3D 0, total_retran=
s =3D 224,=20
  bytes_acked =3D 0, keepalive_time =3D 0, keepalive_intvl =3D 0, linge=
r2 =3D 0,=20
  last_synq_overflow =3D 0, tso_deferred =3D 0, rcv_rtt_est =3D {rtt =3D=
 11331,=20
    seq =3D 3213382083, time =3D 4920502}, rcvq_space =3D {space =3D 31=
540,=20
    seq =3D 3213346721, time =3D 4943716}, mtu_probe =3D {probe_seq_sta=
rt =3D 0,=20
    probe_seq_end =3D 0}}

Thanks.

--=20
Guillaume
