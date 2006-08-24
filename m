From: Piet Delaney <piet@bluelane.com>
Subject: Any one know If tcp timers should look empty when last reference
	to socket has been dropped?
Date: Wed, 23 Aug 2006 20:38:38 -0700
Message-ID: <1156390719.925.290.camel@piet2.bluelane.com>
Reply-To: piet@bluelane.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-gB/uEsIrcYoj/QLvAsub"
Cc: Piet Delaney <piet@bluelane.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mse2fe2.mse2.exchange.ms ([66.232.26.194]:62135 "EHLO
	mse2fe2.mse2.exchange.ms") by vger.kernel.org with ESMTP
	id S1030256AbWHXDin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:38:43 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-gB/uEsIrcYoj/QLvAsub
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hey Gang:

I just re-subscribed to netdev.... Earlier today I  brought up 
something I don't understand with some of the heavy weights
but still don't feel I understand what's happening. It could
be a kgdb cache flushing problem or some magic/land-mines
in the kernel that I'm not familiar with. 

We are running a modified 2.6.12 kernel, yea I know that's
old -- we are working on that.  In the past I've expected the
timer list to "look empty" when the sock structure is released;
that is when the refcnt drops to zero.

Shouldn't the tcp timers have LIST_POISON1 and LIST_POISON2
in their list heads when we drop the last reference to a sk?

We noticed our tcp timers have unexpected values in them
and wondering how to explain it. 

Attached is a copy of a tcp_sock just prior to our freeing it;
as see by kgdb on our 2.6.12 with tcp modified to support being
a proxy. The structure members without sk_ prefixed to it are
additional info that we have added to implement a TCP proxy.

sk->sk_timer looks as expected with LIST_POISON in both list
head pointers. 

The retransmit_timer on the other hand appears to have valid
pointers in it, so I'm wondering if we have a timer reference
count problem.

The tcp_sock is zero'd out on allocation, so I doubt it's 
just stale pointers from a previous incarnation of a tcp_sock.

The delack_timer also has absurd values in it.

I'll add some debug code to try to understand this; if any
of you have some thought on this, it might save me some time
trying to understanding it.
 
-piet

-- 
Piet Delaney
BlueLane Teck
W: (408) 200-5256; piet@bluelane.com
H: (408) 243-8872; piet@piet.net


--=-gB/uEsIrcYoj/QLvAsub
Content-Disposition: attachment; filename=tcp_timers
Content-Type: text/plain; name=tcp_timers; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

(gdb) print *second_saved_tcp_sk
$4 =3D {
  inet =3D {
    sk =3D {
      __sk_common =3D {
        skc_family =3D 2,=20
        skc_state =3D 7 '\a',=20
        skc_reuse =3D 0 '\0',=20
        skc_bound_dev_if =3D 0,=20
        skc_node =3D {
          next =3D 0x0,=20
          pprev =3D 0x0
        },=20
        skc_bind_node =3D {
          next =3D 0x0,=20
          pprev =3D 0x0
        },=20
        skc_refcnt =3D {
          counter =3D 1
        }
      },=20
      sk_shutdown =3D 3 '\003',=20
      sk_no_check =3D 0 '\0',=20
      sk_userlocks =3D 0 '\0',=20
      sk_protocol =3D 6 '\006',=20
      sk_type =3D 1,=20
      sk_rcvbuf =3D 87380,=20
      sk_lock =3D {
        slock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        },=20
        owner =3D 0x0,=20
        wq =3D {
          lock =3D {
            slock =3D 1,=20
            magic =3D 3735899821
          },=20
          task_list =3D {
            next =3D 0xe779054c,=20
            prev =3D 0xe779054c
          }
        }
      },=20
      sk_sleep =3D 0x0,=20
      sk_dst_cache =3D 0x0,=20
      sk_policy =3D         {0x0,
        0x0},=20
      sk_dst_lock =3D {
        lock =3D 16777216,=20
        magic =3D 3736018669
      },=20
      sk_rmem_alloc =3D {
        counter =3D 0
      },=20
      sk_wmem_alloc =3D {
        counter =3D 0
      },=20
      sk_omem_alloc =3D {
        counter =3D 0
      },=20
      sk_receive_queue =3D {
        next =3D 0xe7790578,=20
        prev =3D 0xe7790578,=20
        qlen =3D 0,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        }
      },=20
      sk_write_queue =3D {
        next =3D 0xe779058c,=20
        prev =3D 0xe779058c,=20
        qlen =3D 0,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        }
      },=20
      sk_wmem_queued =3D 0,=20
      sk_forward_alloc =3D 0,=20
      sk_allocation =3D 208,=20
      sk_sndbuf =3D 16384,=20
      sk_route_caps =3D 7081,=20
      sk_hashent =3D 260506,=20
      sk_flags =3D 49929,=20
      sk_lingertime =3D 0,=20
      sk_backlog =3D {
        head =3D 0x0,=20
        tail =3D 0x0
      },=20
      sk_error_queue =3D {
        next =3D 0xe77905c8,=20
        prev =3D 0xe77905c8,=20
        qlen =3D 0,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        }
      },=20
      sk_prot =3D 0xc06befe0,=20
      sk_prot_creator =3D 0xc06befe0,=20
      sk_callback_lock =3D {
        lock =3D 16777216,=20
        magic =3D 3736018669
      },=20
      sk_err =3D 104,=20
      sk_err_soft =3D 0,=20
      sk_ack_backlog =3D 0,=20
      sk_max_ack_backlog =3D 8192,=20
      sk_priority =3D 0,=20
      sk_peercred =3D {
        pid =3D 0,=20
        uid =3D 4294967295,=20
        gid =3D 4294967295
      },=20
      sk_rcvlowat =3D 1,=20
      sk_rcvtimeo =3D 2147483647,=20
      sk_sndtimeo =3D 2147483647,=20
      sk_filter =3D 0x0,=20
      sk_protinfo =3D 0x0,=20
      sk_timer =3D {
        entry =3D {
          next =3D 0x100100,=20
          prev =3D 0x200200
        },=20
        expires =3D 7723632,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        },=20
        magic =3D 1267182958,=20
        function =3D 0xc045e090 <tcp_keepalive_timer>,=20
        data =3D 3883468052,=20
        base =3D 0x0
      },=20
      sk_stamp =3D {
        tv_sec =3D -1,=20
        tv_usec =3D -1
      },=20
      sk_socket =3D 0x0,=20
      sk_user_data =3D 0x0,=20
      sk_sndmsg_page =3D 0x0,=20
      sk_send_head =3D 0x0,=20
      sk_sndmsg_off =3D 0,=20
      sk_write_pending =3D 0,=20
      sk_security =3D 0x0,=20
      sk_state_change =3D 0xc03b5c05 <sock_def_wakeup>,=20
      sk_data_ready =3D 0xc03b5d1e <sock_def_readable>,=20
      sk_write_space =3D 0xc03c4db5 <sk_stream_write_space>,=20
      sk_error_report =3D 0xc03b5c84 <sock_def_error_report>,=20
      sk_backlog_rcv =3D 0xc0466cca <tcp_v4_do_rcv>,=20
      sk_destruct =3D 0xc049857e <inet_sock_destruct>,=20
      peer_sock =3D 0xe7790a04,=20
      socket_type =3D 2,=20
      peer_sk_state =3D 7 '\a',=20
      flag_tcp_done =3D 1 '\001',=20
      flag_tcp_destroy =3D 1 '\001',=20
      flag_write_queue_purge =3D 1 '\001',=20
      flag_new_server_ack =3D 0 '\0',=20
      do_rst_processing =3D 0 '\0',=20
      do_srv_finack_processing =3D 0 '\0',=20
      rst_processing_done =3D 1 '\001',=20
      flag_tw_present =3D 0 '\0',=20
      default_ttl =3D 64 '@',=20
      tcp_close_processing_index =3D 0,=20
      conndev =3D 0xc25ff000,=20
      ha =3D         "\000\023Fd=E83", '\0' <repeats 25 times>,=20
      l2type =3D 0 '\0',=20
      l2addlen =3D 0 '\0',=20
      l2header =3D         '\0' <repeats 31 times>,=20
      vproxy_wmem_queued_data_size =3D 0,=20
      vproxy_max_ubytes =3D 128000,=20
      sk_umem_alloc =3D 0,=20
      sk_ubytes_alloc =3D 0,=20
      num_backlogged_packet =3D 0,=20
      ready_list =3D {
        next =3D 0xe77906ec,=20
        prev =3D 0xe77906ec
      },=20
      user_zbuf_queue =3D {
        next =3D 0xe77906f4,=20
        prev =3D 0xe77906f4
      },=20
      vproxy_id =3D 0,=20
      listener_id =3D 0,=20
      socket_fd =3D -1,=20
      thrd_id =3D 0,=20
      proper_close_flag =3D 0 '\0',=20
      accepted_flag =3D 0 '\0',=20
      close_sent_flag =3D 0 '\0',=20
      close_with_reset =3D 0 '\0',=20
      synq_high_water_mark =3D 1,=20
      acceptq_high_water_mark =3D 1,=20
      backlog_accept_queue =3D 0x0,=20
      backlog_accept_queue_tail =3D 0x0,=20
      sk_backlog_acceptq_len =3D 0,=20
      backlog_acceptq_high_water_mark =3D 0,=20
      peer_clock =3D 4053694621,=20
      default_protocol =3D 2048,=20
      dproxy_port =3D 0,=20
      sa_session_id =3D 7,=20
      recv_tstamp =3D 0
    },=20
    daddr =3D 0,=20
    rcv_saddr =3D 0,=20
    dport =3D 0,=20
    num =3D 0,=20
    saddr =3D 3885070188,=20
    uc_ttl =3D 31132,=20
    cmsg_flags =3D 59281,=20
    opt =3D 0xe791776c,=20
    sport =3D 31132,=20
    id =3D 59281,=20
    tos =3D 2 '\002',=20
    mc_ttl =3D 0 '\0',=20
    pmtudisc =3D 8 '\b',=20
    recverr =3D 0,=20
    freebind =3D 0,=20
    hdrincl =3D 0,=20
    mc_loop =3D 0,=20
    mc_index =3D 0,=20
    mc_addr =3D 0,=20
    mc_list =3D 0xc2b449a8,=20
    cork =3D {
      flags =3D 0,=20
      fragsize =3D 0,=20
      opt =3D 0x7,=20
      rt =3D 0x10603,=20
      length =3D 133792,=20
      addr =3D 1,=20
      fl =3D {
        oif =3D -559067475,=20
        iif =3D 0,=20
        nl_u =3D {
          ip4_u =3D {
            daddr =3D 1,=20
            saddr =3D 3735899821,=20
            fwmark =3D 3883469372,=20
            tos =3D 60 '<',=20
            scope =3D 10 '\n'
          },=20
          ip6_u =3D {
            daddr =3D {
              in6_u =3D {
                u6_addr8 =3D                   "\001\000\000\000=ADN=AD=DE<=
\ny=E7<\ny=E7",=20
                u6_addr16 =3D                   {1,
                  0,
                  20141,
                  57005,
                  2620,
                  59257,
                  2620,
                  59257},=20
                u6_addr32 =3D                   {1,
                  3735899821,
                  3883469372,
                  3883469372}
              }
            },=20
            saddr =3D {
              in6_u =3D {
                u6_addr8 =3D                   '\0' <repeats 15 times>,=20
                u6_addr16 =3D                   {0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0},=20
                u6_addr32 =3D                   {0,
                  0,
                  0,
                  0}
              }
            },=20
            flowlabel =3D 16777216
          },=20
          dn_u =3D {
            daddr =3D 1,=20
            saddr =3D 0,=20
            fwmark =3D 3735899821,=20
            scope =3D 60 '<'
          }
        },=20
        proto =3D 237 '=ED',=20
        flags =3D 30 '\036',=20
        uli_u =3D {
          ports =3D {
            sport =3D 0,=20
            dport =3D 0
          },=20
          icmpt =3D {
            type =3D 0 '\0',=20
            code =3D 0 '\0'
          },=20
          dnports =3D {
            sport =3D 0,=20
            dport =3D 0,=20
            objnum =3D 0 '\0',=20
            objnamel =3D 0 '\0',=20
            objname =3D               "\000\000\000\000\000\000h\ny=E7h\ny=
=E7\000"
          },=20
          spi =3D 0
        }
      }
    }
  },=20
  tcp_header_len =3D 1,=20
  pred_flags =3D 3735899821,=20
  rcv_nxt =3D 3883469436,=20
  snd_nxt =3D 3883469436,=20
  snd_una =3D 0,=20
  snd_sml =3D 1,=20
  rcv_tstamp =3D 3735899821,=20
  lsndtime =3D 0,=20
  bind_hash =3D 0x0,=20
  ack =3D {
    pending =3D 208 '=D0',=20
    quick =3D 0 '\0',=20
    pingpong =3D 0 '\0',=20
    blocked =3D 0 '\0',=20
    ato =3D 16384,=20
    timeout =3D 7081,=20
    lrcvtime =3D 214170,=20
    last_seg_size =3D 33547,=20
    rcv_mss =3D 0
  },=20
  ucopy =3D {
    prequeue =3D {
      next =3D 0x0,=20
      prev =3D 0x0,=20
      qlen =3D 0,=20
      lock =3D {
        slock =3D 3883469496,=20
        magic =3D 3883469496
      }
    },=20
    task =3D 0x0,=20
    iov =3D 0x1,=20
    memory =3D -559067475,=20
    len =3D -1066668064
  },=20
  snd_wl1 =3D 3228299232,=20
  snd_wnd =3D 16777216,=20
  max_window =3D 3736018669,=20
  pmtu_cookie =3D 0,=20
  mss_cache =3D 0,=20
  mss_cache_std =3D 0,=20
  ext_header_len =3D 8192,=20
  ca_state =3D 0 '\0',=20
  retransmits =3D 0 '\0',=20
  advmss =3D 0,=20
  window_clamp =3D 0,=20
  rcv_ssthresh =3D 4294967295,=20
  frto_highmark =3D 4294967295,=20
  reordering =3D 1 '\001',=20
  frto_counter =3D 0 '\0',=20
  adv_cong =3D 0 '\0',=20
  defer_accept =3D 0 '\0',=20
  srtt =3D 2147483647,=20
  mdev =3D 2147483647,=20
  mdev_max =3D 0,=20
  rttvar =3D 0,=20
  rtt_seq =3D 3883468316,=20
  rto =3D 3254917928,=20
  packets_out =3D 7723632,=20
  left_out =3D 1,=20
  retrans_out =3D 3735899821,=20
  backoff =3D 110 'n',=20
  nonagle =3D 173 '=AD',=20
  keepalive_probes =3D 135 '\207',=20
  probes_out =3D 75 'K',=20
  rx_opt =3D {
    ts_recent_stamp =3D -1069162352,=20
    ts_recent =3D 3883469316,=20
    rcv_tsval =3D 3254914784,=20
    rcv_tsecr =3D 4294967295,=20
    saw_tstamp =3D 1,=20
    tstamp_ok =3D 1,=20
    dsack =3D 1,=20
    wscale_ok =3D 1,=20
    sack_ok =3D 15,=20
    snd_wscale =3D 15,=20
    rcv_wscale =3D 15,=20
    eff_sacks =3D 255 '=FF',=20
    num_sacks =3D 255 '=FF',=20
    user_mss =3D 0,=20
    mss_clamp =3D 0
  },=20
  snd_ssthresh =3D 0,=20
  snd_cwnd =3D 0,=20
  snd_cwnd_cnt =3D 0,=20
  snd_cwnd_clamp =3D 0,=20
  snd_cwnd_used =3D 0,=20
  snd_cwnd_stamp =3D 0,=20
  timeout =3D 0,=20
  retransmit_timer =3D {
    entry =3D {
      next =3D 0xc0533cd2,=20
      prev =3D 0xc0533cf2
    },=20
    expires =3D 3225177525,=20
    lock =3D {
      slock =3D 3226680535,=20
      magic =3D 3225840842
    },=20
    magic =3D 3226043774,=20
    function =3D 0xe7790514,=20
    data =3D 262145,=20
    base =3D 0x0
  },=20
  delack_timer =3D {
    entry =3D {
      next =3D 0x40000000,=20
      prev =3D 0x0
    },=20
    expires =3D 3261071360,=20
    lock =3D {
      slock =3D 33263616,=20
      magic =3D 20134
    },=20
    magic =3D 0,=20
    function =3D 0,=20
    data =3D 0,=20
    base =3D 0x0
  },=20
  out_of_order_queue =3D {
    next =3D 0x0,=20
    prev =3D 0x0,=20
    qlen =3D 0,=20
    lock =3D {
      slock =3D 0,=20
      magic =3D 0
    }
  },=20
  af_specific =3D 0x0,=20
  rcv_wnd =3D 0,=20
  rcv_wup =3D 0,=20
  write_seq =3D 0,=20
  pushed_seq =3D 0,=20
  copied_seq =3D 0,=20
  duplicate_sack =3D     {{
      start_seq =3D 0,=20
      end_seq =3D 128000
    }},=20
  selective_acks =3D     {{
      start_seq =3D 0,=20
      end_seq =3D 0
    },
    {
      start_seq =3D 0,=20
      end_seq =3D 3883469788
    },
    {
      start_seq =3D 3883469788,=20
      end_seq =3D 3883469796
    },
    {
      start_seq =3D 3883469796,=20
      end_seq =3D 3
    }},=20
  syn_retries =3D 1 '\001',=20
  ecn_flags =3D 0 '\0',=20
  prior_ssthresh =3D 0,=20
  lost_out =3D 33,=20
  sacked_out =3D 1,=20
  fackets_out =3D 65793,=20
  high_seq =3D 1,=20
  retrans_stamp =3D 1,=20
  undo_marker =3D 0,=20
  undo_retrans =3D 0,=20
  urg_seq =3D 0,=20
  urg_data =3D 0,=20
  pending =3D 0 '\0',=20
  urg_mode =3D 0 '\0',=20
  snd_up =3D 4053696949,=20
  total_retrans =3D 2048,=20
  syn_wait_lock =3D {
    lock =3D 7,=20
    magic =3D 0
  },=20
  listen_opt =3D 0x0,=20
  accept_queue =3D 0x0,=20
  accept_queue_tail =3D 0x296,=20
  keepalive_time =3D 262146,=20
  keepalive_intvl =3D 0,=20
  linger2 =3D 0,=20
  last_synq_overflow =3D 3267336616,=20
  rcv_rtt_est =3D {
    rtt =3D 0,=20
    seq =3D 0,=20
    time =3D 6
  },=20
  rcvq_space =3D {
    space =3D 67072,=20
    seq =3D 87380,=20
    time =3D 1
  },=20
  westwood =3D {
    bw_ns_est =3D 3735899821,=20
    bw_est =3D 0,=20
    rtt_win_sx =3D 1,=20
    bk =3D 3735899821,=20
    snd_una =3D 3883468108,=20
    cumul_ack =3D 3883468108,=20
    accounted =3D 0,=20
    rtt =3D 0,=20
    rtt_min =3D 0
  },=20
  vegas =3D {
    beg_snd_nxt =3D 0,=20
    beg_snd_una =3D 16777216,=20
    beg_snd_cwnd =3D 3736018669,=20
    doing_vegas_now =3D 0 '\0',=20
    cntRTT =3D 0,=20
    minRTT =3D 0,=20
    baseRTT =3D 0
  },=20
  bictcp =3D {
    cnt =3D 3883468152,=20
    last_max_cwnd =3D 3883468152,=20
    last_cwnd =3D 0,=20
    last_stamp =3D 1
  }
}
(gdb)=20

--=-gB/uEsIrcYoj/QLvAsub--

