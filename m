From: Piet Delaney <piet@bluelane.com>
Subject: Re: Any one know If tcp timers should look empty when last
	reference to socket has been dropped?
Date: Fri, 25 Aug 2006 17:05:05 -0700
Message-ID: <1156550706.925.343.camel@piet2.bluelane.com>
References: <1156390719.925.290.camel@piet2.bluelane.com>
Reply-To: piet@bluelane.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-03NM6+8xqkc0tMd5XGMP"
Cc: Piet Delaney <piet@bluelane.com>,
	Subhachandra Chandra <schandra@bluelane.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mse2fe2.mse2.exchange.ms ([66.232.26.194]:34920 "EHLO
	mse2fe2.mse2.exchange.ms") by vger.kernel.org with ESMTP
	id S1422936AbWHZAFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 20:05:11 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1156390719.925.290.camel@piet2.bluelane.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-03NM6+8xqkc0tMd5XGMP
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2006-08-23 at 20:38 -0700, Piet Delaney wrote:

I was right, at least for 2.6.12, when we free the
socket the timer should have list poison in them.

 retransmit_timer = {
    entry = {
      next = 0x100100,
      prev = 0x200200
    },
    expires = 44563,
    lock = {
      slock = 1,
      magic = 3735899821
    },
    magic = 1267182958,
    function = 0xc043104a <tcp_write_timer>,
    data = 3884627220,
    base = 0x0
  },

Problem was just my looking at the tcp_sock but
having only saved the sock part.

-piet

> Hey Gang:
> 
> I just re-subscribed to netdev.... Earlier today I  brought up 
> something I don't understand with some of the heavy weights
> but still don't feel I understand what's happening. It could
> be a kgdb cache flushing problem or some magic/land-mines
> in the kernel that I'm not familiar with. 
> 
> We are running a modified 2.6.12 kernel, yea I know that's
> old -- we are working on that.  In the past I've expected the
> timer list to "look empty" when the sock structure is released;
> that is when the refcnt drops to zero.
> 
> Shouldn't the tcp timers have LIST_POISON1 and LIST_POISON2
> in their list heads when we drop the last reference to a sk?
> 
> We noticed our tcp timers have unexpected values in them
> and wondering how to explain it. 
> 
> Attached is a copy of a tcp_sock just prior to our freeing it;
> as see by kgdb on our 2.6.12 with tcp modified to support being
> a proxy. The structure members without sk_ prefixed to it are
> additional info that we have added to implement a TCP proxy.
> 
> sk->sk_timer looks as expected with LIST_POISON in both list
> head pointers. 
> 
> The retransmit_timer on the other hand appears to have valid
> pointers in it, so I'm wondering if we have a timer reference
> count problem.
> 
> The tcp_sock is zero'd out on allocation, so I doubt it's 
> just stale pointers from a previous incarnation of a tcp_sock.
> 
> The delack_timer also has absurd values in it.
> 
> I'll add some debug code to try to understand this; if any
> of you have some thought on this, it might save me some time
> trying to understanding it.
>  
> -piet
> 
-- 
Piet Delaney
BlueLane Teck
W: (408) 200-5256; piet@bluelane.com
H: (408) 243-8872; piet@piet.net


--=-03NM6+8xqkc0tMd5XGMP
Content-Disposition: attachment; filename=socket_when_made_free
Content-Type: text/plain; name=socket_when_made_free; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

(gdb) print second_saved_tcp_sk
$1 =3D {
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
            next =3D 0xe78ab54c,=20
            prev =3D 0xe78ab54c
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
        next =3D 0xe78ab578,=20
        prev =3D 0xe78ab578,=20
        qlen =3D 0,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        }
      },=20
      sk_write_queue =3D {
        next =3D 0xe78ab58c,=20
        prev =3D 0xe78ab58c,=20
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
      sk_hashent =3D 242205,=20
      sk_flags =3D 49929,=20
      sk_lingertime =3D 0,=20
      sk_backlog =3D {
        head =3D 0x0,=20
        tail =3D 0x0
      },=20
      sk_error_queue =3D {
        next =3D 0xe78ab5c8,=20
        prev =3D 0xe78ab5c8,=20
        qlen =3D 0,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        }
      },=20
      sk_prot =3D 0xc0615fe0,=20
      sk_prot_creator =3D 0xc0615fe0,=20
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
        expires =3D 7243360,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        },=20
        magic =3D 1267182958,=20
        function =3D 0xc0431643 <tcp_keepalive_timer>,=20
        data =3D 3884627220,=20
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
      sk_state_change =3D 0xc03ad479 <sock_def_wakeup>,=20
      sk_data_ready =3D 0xc03ad592 <sock_def_readable>,=20
      sk_write_space =3D 0xc03bc71d <sk_stream_write_space>,=20
      sk_error_report =3D 0xc03ad4f8 <sock_def_error_report>,=20
      sk_backlog_rcv =3D 0xc04375f7 <tcp_v4_do_rcv>,=20
      sk_destruct =3D 0xc0457e4a <inet_sock_destruct>,=20
      peer_sock =3D 0xe78aba04,=20
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
      conndev =3D 0xc25e9000,=20
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
        next =3D 0xe78ab6ec,=20
        prev =3D 0xe78ab6ec
      },=20
      user_zbuf_queue =3D {
        next =3D 0xe78ab6f4,=20
        prev =3D 0xe78ab6f4
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
      peer_clock =3D 75995319,=20
      default_protocol =3D 2048,=20
      dproxy_port =3D 0,=20
      sa_session_id =3D 18,=20
      recv_tstamp =3D 0
    },=20
    daddr =3D 638298304,=20
    rcv_saddr =3D 17541312,=20
    dport =3D 20480,=20
    num =3D 50607,=20
    saddr =3D 17541312,=20
    uc_ttl =3D -1,=20
    cmsg_flags =3D 0,=20
    opt =3D 0x0,=20
    sport =3D 44997,=20
    id =3D 23278,=20
    tos =3D 0 '\0',=20
    mc_ttl =3D 1 '\001',=20
    pmtudisc =3D 1 '\001',=20
    recverr =3D 0,=20
    freebind =3D 0,=20
    hdrincl =3D 0,=20
    mc_loop =3D 1,=20
    mc_index =3D 0,=20
    mc_addr =3D 0,=20
    mc_list =3D 0x0,=20
    cork =3D {
      flags =3D 0,=20
      fragsize =3D 0,=20
      opt =3D 0x0,=20
      rt =3D 0x0,=20
      length =3D 0,=20
      addr =3D 0,=20
      fl =3D {
        oif =3D 0,=20
        iif =3D 0,=20
        nl_u =3D {
          ip4_u =3D {
            daddr =3D 0,=20
            saddr =3D 0,=20
            fwmark =3D 0,=20
            tos =3D 0 '\0',=20
            scope =3D 0 '\0'
          },=20
          ip6_u =3D {
            daddr =3D {
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
            flowlabel =3D 0
          },=20
          dn_u =3D {
            daddr =3D 0,=20
            saddr =3D 0,=20
            fwmark =3D 0,=20
            scope =3D 0 '\0'
          }
        },=20
        proto =3D 0 '\0',=20
        flags =3D 0 '\0',=20
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
            objname =3D               '\0' <repeats 15 times>
          },=20
          spi =3D 0
        }
      }
    }
  },=20
  tcp_header_len =3D 32,=20
  pred_flags =3D 0,=20
  rcv_nxt =3D 4215893076,=20
  snd_nxt =3D 3915183010,=20
  snd_una =3D 3915183009,=20
  snd_sml =3D 3915183010,=20
  rcv_tstamp =3D 43361,=20
  lsndtime =3D 43361,=20
  bind_hash =3D 0x0,=20
  ack =3D {
    pending =3D 0 '\0',=20
    quick =3D 0 '\0',=20
    pingpong =3D 0 '\0',=20
    blocked =3D 0 '\0',=20
    ato =3D 0,=20
    timeout =3D 0,=20
    lrcvtime =3D 0,=20
    last_seg_size =3D 0,=20
    rcv_mss =3D 536
  },=20
  ucopy =3D {
    prequeue =3D {
      next =3D 0xe78ab7fc,=20
      prev =3D 0xe78ab7fc,=20
      qlen =3D 0,=20
      lock =3D {
        slock =3D 1,=20
        magic =3D 3735899821
      }
    },=20
    task =3D 0x0,=20
    iov =3D 0x0,=20
    memory =3D 0,=20
    len =3D 0
  },=20
  snd_wl1 =3D 4215893076,=20
  snd_wnd =3D 5792,=20
  max_window =3D 5792,=20
  pmtu_cookie =3D 1500,=20
  mss_cache =3D 2896,=20
  mss_cache_std =3D 1448,=20
  ext_header_len =3D 0,=20
  ca_state =3D 0 '\0',=20
  retransmits =3D 0 '\0',=20
  advmss =3D 1448,=20
  window_clamp =3D 0,=20
  rcv_ssthresh =3D 0,=20
  frto_highmark =3D 0,=20
  reordering =3D 3 '\003',=20
  frto_counter =3D 0 '\0',=20
  adv_cong =3D 0 '\0',=20
  defer_accept =3D 0 '\0',=20
  srtt =3D 8,=20
  mdev =3D 2,=20
  mdev_max =3D 200,=20
  rttvar =3D 200,=20
  rtt_seq =3D 3915183009,=20
  rto =3D 201,=20
  packets_out =3D 1,=20
  left_out =3D 0,=20
  retrans_out =3D 0,=20
  backoff =3D 0 '\0',=20
  nonagle =3D 1 '\001',=20
  keepalive_probes =3D 0 '\0',=20
  probes_out =3D 0 '\0',=20
  rx_opt =3D {
    ts_recent_stamp =3D 1156574913,=20
    ts_recent =3D 75869935,=20
    rcv_tsval =3D 75870939,=20
    rcv_tsecr =3D 0,=20
    saw_tstamp =3D 1,=20
    tstamp_ok =3D 1,=20
    dsack =3D 0,=20
    wscale_ok =3D 1,=20
    sack_ok =3D 3,=20
    snd_wscale =3D 2,=20
    rcv_wscale =3D 2,=20
    eff_sacks =3D 0 '\0',=20
    num_sacks =3D 0 '\0',=20
    user_mss =3D 0,=20
    mss_clamp =3D 1460
  },=20
  snd_ssthresh =3D 2147483647,=20
  snd_cwnd =3D 16,=20
  snd_cwnd_cnt =3D 0,=20
  snd_cwnd_clamp =3D 65535,=20
  snd_cwnd_used =3D 0,=20
  snd_cwnd_stamp =3D 43361,=20
  timeout =3D 44563,=20
  retransmit_timer =3D {
    entry =3D {
      next =3D 0x100100,=20
      prev =3D 0x200200
    },=20
    expires =3D 44563,=20
    lock =3D {
      slock =3D 1,=20
      magic =3D 3735899821
    },=20
    magic =3D 1267182958,=20
    function =3D 0xc043104a <tcp_write_timer>,=20
    data =3D 3884627220,=20
    base =3D 0x0
  },=20
  delack_timer =3D {
    entry =3D {
      next =3D 0x0,=20
      prev =3D 0x0
    },=20
    expires =3D 0,=20
    lock =3D {
      slock =3D 1,=20
      magic =3D 3735899821
    },=20
    magic =3D 1267182958,=20
    function =3D 0xc0430a34 <tcp_delack_timer>,=20
    data =3D 3884627220,=20
    base =3D 0x0
  },=20
  out_of_order_queue =3D {
    next =3D 0xe78ab8ec,=20
    prev =3D 0xe78ab8ec,=20
    qlen =3D 0,=20
    lock =3D {
      slock =3D 1,=20
      magic =3D 3735899821
    }
  },=20
  af_specific =3D 0xc0615fa0,=20
  rcv_wnd =3D 5840,=20
  rcv_wup =3D 4215893076,=20
  write_seq =3D 3915183010,=20
  pushed_seq =3D 3915182990,=20
  copied_seq =3D 4215893076,=20
  duplicate_sack =3D     {{
      start_seq =3D 0,=20
      end_seq =3D 0
    }},=20
  selective_acks =3D     {{
      start_seq =3D 0,=20
      end_seq =3D 0
    },
    {
      start_seq =3D 0,=20
      end_seq =3D 0
    },
    {
      start_seq =3D 0,=20
      end_seq =3D 0
    },
    {
      start_seq =3D 0,=20
      end_seq =3D 0
    }},=20
  syn_retries =3D 0 '\0',=20
  ecn_flags =3D 0 '\0',=20
  prior_ssthresh =3D 0,=20
  lost_out =3D 0,=20
  sacked_out =3D 0,=20
  fackets_out =3D 0,=20
  high_seq =3D 0,=20
  retrans_stamp =3D 0,=20
  undo_marker =3D 0,=20
  undo_retrans =3D 0,=20
  urg_seq =3D 0,=20
  urg_data =3D 0,=20
  pending =3D 0 '\0',=20
  urg_mode =3D 0 '\0',=20
  snd_up =3D 0,=20
  total_retrans =3D 0,=20
  syn_wait_lock =3D {
    lock =3D 0,=20
    magic =3D 0
  },=20
  listen_opt =3D 0x0,=20
  accept_queue =3D 0x0,=20
  accept_queue_tail =3D 0x0,=20
  keepalive_time =3D 0,=20
  keepalive_intvl =3D 0,=20
  linger2 =3D 0,=20
  last_synq_overflow =3D 0,=20
  rcv_rtt_est =3D {
    rtt =3D 0,=20
    seq =3D 0,=20
    time =3D 0
  },=20
  rcvq_space =3D {
    space =3D 5840,=20
    seq =3D 0,=20
    time =3D 0
  },=20
  westwood =3D {
    bw_ns_est =3D 0,=20
    bw_est =3D 0,=20
    rtt_win_sx =3D 43360,=20
    bk =3D 0,=20
    snd_una =3D 3915182990,=20
    cumul_ack =3D 0,=20
    accounted =3D 0,=20
    rtt =3D 20000,=20
    rtt_min =3D 20000
  },=20
  vegas =3D {
    beg_snd_nxt =3D 0,=20
    beg_snd_una =3D 0,=20
    beg_snd_cwnd =3D 0,=20
    doing_vegas_now =3D 0 '\0',=20
    cntRTT =3D 0,=20
    minRTT =3D 0,=20
    baseRTT =3D 0
  },=20
  bictcp =3D {
    cnt =3D 0,=20
    last_max_cwnd =3D 0,=20
    last_cwnd =3D 0,=20
    last_stamp =3D 0
  }
}
(gdb) print second_saved_peer_tcp_sk
$2 =3D {
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
      sk_rcvbuf =3D 133792,=20
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
            next =3D 0xe78aba3c,=20
            prev =3D 0xe78aba3c
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
        next =3D 0xe78aba68,=20
        prev =3D 0xe78aba68,=20
        qlen =3D 0,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        }
      },=20
      sk_write_queue =3D {
        next =3D 0xe78aba7c,=20
        prev =3D 0xe78aba7c,=20
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
      sk_hashent =3D 231453,=20
      sk_flags =3D 33547,=20
      sk_lingertime =3D 0,=20
      sk_backlog =3D {
        head =3D 0x0,=20
        tail =3D 0x0
      },=20
      sk_error_queue =3D {
        next =3D 0xe78abab8,=20
        prev =3D 0xe78abab8,=20
        qlen =3D 0,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        }
      },=20
      sk_prot =3D 0xc0615fe0,=20
      sk_prot_creator =3D 0xc0615fe0,=20
      sk_callback_lock =3D {
        lock =3D 16777216,=20
        magic =3D 3736018669
      },=20
      sk_err =3D 32,=20
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
        expires =3D 7243360,=20
        lock =3D {
          slock =3D 1,=20
          magic =3D 3735899821
        },=20
        magic =3D 1267182958,=20
        function =3D 0xc0431643 <tcp_keepalive_timer>,=20
        data =3D 3884628484,=20
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
      sk_state_change =3D 0xc04c1339 <sa_tcp_state_change>,=20
      sk_data_ready =3D 0xc04c1359 <sa_tcp_data_ready>,=20
      sk_write_space =3D 0xc03bc71d <sk_stream_write_space>,=20
      sk_error_report =3D 0xc04c133e <sa_tcp_error_report>,=20
      sk_backlog_rcv =3D 0xc04375f7 <tcp_v4_do_rcv>,=20
      sk_destruct =3D 0xc0457e4a <inet_sock_destruct>,=20
      peer_sock =3D 0xe78ab514,=20
      socket_type =3D 1,=20
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
      conndev =3D 0xc25ea000,=20
      ha =3D         "\000\220=FB\001=A6N", '\0' <repeats 25 times>,=20
      l2type =3D 0 '\0',=20
      l2addlen =3D 0 '\0',=20
      l2header =3D         '\0' <repeats 31 times>,=20
      vproxy_wmem_queued_data_size =3D 0,=20
      vproxy_max_ubytes =3D 128000,=20
      sk_umem_alloc =3D 0,=20
      sk_ubytes_alloc =3D 0,=20
      num_backlogged_packet =3D 0,=20
      ready_list =3D {
        next =3D 0xe78abbdc,=20
        prev =3D 0xe78abbdc
      },=20
      user_zbuf_queue =3D {
        next =3D 0xe78abbe4,=20
        prev =3D 0xe78abbe4
      },=20
      vproxy_id =3D 3,=20
      listener_id =3D 1,=20
      socket_fd =3D 33,=20
      thrd_id =3D 1,=20
      proper_close_flag =3D 1 '\001',=20
      accepted_flag =3D 1 '\001',=20
      close_sent_flag =3D 1 '\001',=20
      close_with_reset =3D 0 '\0',=20
      synq_high_water_mark =3D 1,=20
      acceptq_high_water_mark =3D 1,=20
      backlog_accept_queue =3D 0x0,=20
      backlog_accept_queue_tail =3D 0x0,=20
      sk_backlog_acceptq_len =3D 0,=20
      backlog_acceptq_high_water_mark =3D 0,=20
      peer_clock =3D 75870939,=20
      default_protocol =3D 2048,=20
      dproxy_port =3D 0,=20
      sa_session_id =3D 18,=20
      recv_tstamp =3D 0
    },=20
    daddr =3D 17541312,=20
    rcv_saddr =3D 638298304,=20
    dport =3D 44997,=20
    num =3D 80,=20
    saddr =3D 638298304,=20
    uc_ttl =3D -1,=20
    cmsg_flags =3D 0,=20
    opt =3D 0x0,=20
    sport =3D 20480,=20
    id =3D 50484,=20
    tos =3D 0 '\0',=20
    mc_ttl =3D 1 '\001',=20
    pmtudisc =3D 1 '\001',=20
    recverr =3D 0,=20
    freebind =3D 0,=20
    hdrincl =3D 0,=20
    mc_loop =3D 1,=20
    mc_index =3D 0,=20
    mc_addr =3D 0,=20
    mc_list =3D 0x0,=20
    cork =3D {
      flags =3D 0,=20
      fragsize =3D 0,=20
      opt =3D 0x0,=20
      rt =3D 0x0,=20
      length =3D 0,=20
      addr =3D 0,=20
      fl =3D {
        oif =3D 0,=20
        iif =3D 0,=20
        nl_u =3D {
          ip4_u =3D {
            daddr =3D 0,=20
            saddr =3D 0,=20
            fwmark =3D 0,=20
            tos =3D 0 '\0',=20
            scope =3D 0 '\0'
          },=20
          ip6_u =3D {
            daddr =3D {
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
            flowlabel =3D 0
          },=20
          dn_u =3D {
            daddr =3D 0,=20
            saddr =3D 0,=20
            fwmark =3D 0,=20
            scope =3D 0 '\0'
          }
        },=20
        proto =3D 0 '\0',=20
        flags =3D 0 '\0',=20
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
            objname =3D               '\0' <repeats 15 times>
          },=20
          spi =3D 0
        }
      }
    }
  },=20
  tcp_header_len =3D 32,=20
  pred_flags =3D 3020230784,=20
  rcv_nxt =3D 3915183010,=20
  snd_nxt =3D 4215893076,=20
  snd_una =3D 4215893076,=20
  snd_sml =3D 4215893076,=20
  rcv_tstamp =3D 44362,=20
  lsndtime =3D 43360,=20
  bind_hash =3D 0x0,=20
  ack =3D {
    pending =3D 0 '\0',=20
    quick =3D 1 '\001',=20
    pingpong =3D 1 '\001',=20
    blocked =3D 0 '\0',=20
    ato =3D 40,=20
    timeout =3D 44402,=20
    lrcvtime =3D 43360,=20
    last_seg_size =3D 0,=20
    rcv_mss =3D 536
  },=20
  ucopy =3D {
    prequeue =3D {
      next =3D 0xe78abcec,=20
      prev =3D 0xe78abcec,=20
      qlen =3D 0,=20
      lock =3D {
        slock =3D 1,=20
        magic =3D 3735899821
      }
    },=20
    task =3D 0x0,=20
    iov =3D 0x0,=20
    memory =3D 0,=20
    len =3D 0
  },=20
  snd_wl1 =3D 3915183009,=20
  snd_wnd =3D 5840,=20
  max_window =3D 5840,=20
  pmtu_cookie =3D 1500,=20
  mss_cache =3D 1448,=20
  mss_cache_std =3D 1448,=20
  ext_header_len =3D 0,=20
  ca_state =3D 0 '\0',=20
  retransmits =3D 0 '\0',=20
  advmss =3D 1448,=20
  window_clamp =3D 98896,=20
  rcv_ssthresh =3D 2920,=20
  frto_highmark =3D 0,=20
  reordering =3D 3 '\003',=20
  frto_counter =3D 0 '\0',=20
  adv_cong =3D 0 '\0',=20
  defer_accept =3D 0 '\0',=20
  srtt =3D 0,=20
  mdev =3D 3000,=20
  mdev_max =3D 0,=20
  rttvar =3D 0,=20
  rtt_seq =3D 0,=20
  rto =3D 3000,=20
  packets_out =3D 0,=20
  left_out =3D 0,=20
  retrans_out =3D 0,=20
  backoff =3D 0 '\0',=20
  nonagle =3D 1 '\001',=20
  keepalive_probes =3D 0 '\0',=20
  probes_out =3D 0 '\0',=20
  rx_opt =3D {
    ts_recent_stamp =3D 1156574914,=20
    ts_recent =3D 75995319,=20
    rcv_tsval =3D 75995319,=20
    rcv_tsecr =3D 75869935,=20
    saw_tstamp =3D 1,=20
    tstamp_ok =3D 1,=20
    dsack =3D 0,=20
    wscale_ok =3D 1,=20
    sack_ok =3D 3,=20
    snd_wscale =3D 2,=20
    rcv_wscale =3D 2,=20
    eff_sacks =3D 0 '\0',=20
    num_sacks =3D 0 '\0',=20
    user_mss =3D 0,=20
    mss_clamp =3D 1460
  },=20
  snd_ssthresh =3D 2147483647,=20
  snd_cwnd =3D 2,=20
  snd_cwnd_cnt =3D 0,=20
  snd_cwnd_clamp =3D 65535,=20
  snd_cwnd_used =3D 0,=20
  snd_cwnd_stamp =3D 43360,=20
  timeout =3D 0,=20
  retransmit_timer =3D {
    entry =3D {
      next =3D 0x0,=20
      prev =3D 0x0
    },=20
    expires =3D 0,=20
    lock =3D {
      slock =3D 1,=20
      magic =3D 3735899821
    },=20
    magic =3D 1267182958,=20
    function =3D 0xc043104a <tcp_write_timer>,=20
    data =3D 3884628484,=20
    base =3D 0x0
  },=20
  delack_timer =3D {
    entry =3D {
      next =3D 0x100100,=20
      prev =3D 0x200200
    },=20
    expires =3D 44402,=20
    lock =3D {
      slock =3D 1,=20
      magic =3D 3735899821
    },=20
    magic =3D 1267182958,=20
    function =3D 0xc0430a34 <tcp_delack_timer>,=20
    data =3D 3884628484,=20
    base =3D 0x0
  },=20
  out_of_order_queue =3D {
    next =3D 0xe78abddc,=20
    prev =3D 0xe78abddc,=20
    qlen =3D 0,=20
    lock =3D {
      slock =3D 1,=20
      magic =3D 3735899821
    }
  },=20
  af_specific =3D 0xc0615fa0,=20
  rcv_wnd =3D 2920,=20
  rcv_wup =3D 3915183010,=20
  write_seq =3D 4215893076,=20
  pushed_seq =3D 4215893076,=20
  copied_seq =3D 3915183010,=20
  duplicate_sack =3D     {{
      start_seq =3D 0,=20
      end_seq =3D 0
    }},=20
  selective_acks =3D     {{
      start_seq =3D 0,=20
      end_seq =3D 0
    },
    {
      start_seq =3D 0,=20
      end_seq =3D 0
    },
    {
      start_seq =3D 0,=20
      end_seq =3D 0
    },
    {
      start_seq =3D 0,=20
      end_seq =3D 0
    }},=20
  syn_retries =3D 0 '\0',=20
  ecn_flags =3D 0 '\0',=20
  prior_ssthresh =3D 0,=20
  lost_out =3D 0,=20
  sacked_out =3D 0,=20
  fackets_out =3D 0,=20
  high_seq =3D 0,=20
  retrans_stamp =3D 0,=20
  undo_marker =3D 0,=20
  undo_retrans =3D 0,=20
  urg_seq =3D 0,=20
  urg_data =3D 0,=20
  pending =3D 0 '\0',=20
  urg_mode =3D 0 '\0',=20
  snd_up =3D 0,=20
  total_retrans =3D 0,=20
  syn_wait_lock =3D {
    lock =3D 0,=20
    magic =3D 0
  },=20
  listen_opt =3D 0x0,=20
  accept_queue =3D 0x0,=20
  accept_queue_tail =3D 0x0,=20
  keepalive_time =3D 0,=20
  keepalive_intvl =3D 0,=20
  linger2 =3D 0,=20
  last_synq_overflow =3D 0,=20
  rcv_rtt_est =3D {
    rtt =3D 0,=20
    seq =3D 3915185929,=20
    time =3D 43360
  },=20
  rcvq_space =3D {
    space =3D 2920,=20
    seq =3D 0,=20
    time =3D 0
  },=20
  westwood =3D {
    bw_ns_est =3D 0,=20
    bw_est =3D 0,=20
    rtt_win_sx =3D 43360,=20
    bk =3D 0,=20
    snd_una =3D 4215893076,=20
    cumul_ack =3D 0,=20
    accounted =3D 0,=20
    rtt =3D 20000,=20
    rtt_min =3D 20000
  },=20
  vegas =3D {
    beg_snd_nxt =3D 0,=20
    beg_snd_una =3D 0,=20
    beg_snd_cwnd =3D 0,=20
    doing_vegas_now =3D 0 '\0',=20
    cntRTT =3D 0,=20
    minRTT =3D 0,=20
    baseRTT =3D 0
  },=20
  bictcp =3D {
    cnt =3D 0,=20
    last_max_cwnd =3D 0,=20
    last_cwnd =3D 0,=20
    last_stamp =3D 0
  }
}
(gdb) where
#0  atomic_dec_and_test (v=3D0x6b6b6b83) at atomic.h:135
#1  0xc04a915b in sock_put (sk=3D0x6b6b6b6b, file=3D0xc058d3cc "net/ipv4/..=
/../../secureall-kernel/vproxy/sa_tcp_input.c", line=3D1644) at sock.h:976
#2  0xc04acdfb in sa_tcp_v4_rcv (skb=3D0xe75387dc) at net/ipv4/../../../sec=
ureall-kernel/vproxy/sa_tcp_input.c:1644
#3  0xc0431e98 in vproxy_tcp_rcv (sk=3D0x0, skb=3D0x6b6b6b83, vi=3D0xe78ab0=
00) at vproxy.h:320
#4  0xc0437777 in tcp_v4_rcv (skb=3D0xe75387dc) at net/ipv4/tcp_ipv4.c:1775
#5  0xc0403af1 in ip_local_deliver_finish (skb=3D0xe75387dc) at net/ipv4/ip=
_input.c:242
#6  0xc0404194 in vproxy_ip_local_deliver_finish (skb=3D0x6b6b6b83) at net/=
ipv4/ip_input.c:441
#7  0xc049dd49 in ip_handler (skb=3D0xe75387dc) at net/ipv4/../../../secure=
all-kernel/vproxy/vproxy.c:803
#8  0xc049e2a4 in bridge_handler (skb=3D0xe75387dc, outdev=3D0x6b6b6b83) at=
 net/ipv4/../../../secureall-kernel/vproxy/vproxy.c:1081
#9  0xc03c4678 in vproxy_bridge_handler (skb=3D0xe75387dc, outdev=3D0xc25ea=
000, vi=3D0xc264389c) at vproxy.h:271
#10 0xc03c8d8c in netif_receive_skb (skb=3D0xe75387dc) at net/core/dev.c:17=
50
#11 0xc029412f in e1000_clean_rx_irq (adapter=3D0xc25e9240, work_done=3D0xe=
7a0bf20, work_to_do=3D64) at drivers/net/e1000/e1000_main.c:2947
#12 0xc02935de in e1000_clean (netdev=3D0xc25e9000, budget=3D0xe7a0bf5c) at=
 drivers/net/e1000/e1000_main.c:2674
#13 0xc03c939b in net_rx_action (h=3D0xc068a418) at net/core/dev.c:1865
#14 0xc0124a8c in __do_softirq () at kernel/softirq.c:95
#15 0xc0124b2d in do_softirq () at kernel/softirq.c:129
#16 0xc0124be4 in irq_exit () at kernel/softirq.c:169
#17 0xc0105cfe in do_IRQ (regs=3D0xe7a0bfbc) at arch/i386/kernel/irq.c:107
#18 0xc0103faa in common_interrupt () at atomic.h:216
#19 0xc05aad99 in end_of_stack_stop_unwind_function ()
#20 0xc05aad99 in end_of_stack_stop_unwind_function ()
(gdb)=20

--=-03NM6+8xqkc0tMd5XGMP--

