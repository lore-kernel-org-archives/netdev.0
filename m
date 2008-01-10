From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Thu, 10 Jan 2008 15:53:13 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801092151550.3324@kivilampi-30.cs.helsinki.fi>
References: <20080108020529.GC16156@one.firstfloor.org>
 <20080107.193700.159646842.davem@davemloft.net> <20080108050007.GA25338@one.firstfloor.org>
 <20080107.211018.160153013.davem@davemloft.net>
 <Pine.LNX.4.64.0801081228010.12911@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-154144947-1199909625=:3324"
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	paul.moore@hp.com, latten@us.ibm.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44697 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbYAJNxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 08:53:16 -0500
In-Reply-To: <Pine.LNX.4.64.0801081228010.12911@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0801101539250.6607@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-154144947-1199909625=:3324
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0801092215191.3324@kivilampi-30.cs.helsinki.fi>

On Tue, 8 Jan 2008, Ilpo Järvinen wrote:

> On Mon, 7 Jan 2008, David Miller wrote:
> 
> > From: Andi Kleen <andi@firstfloor.org>
> > Date: Tue, 8 Jan 2008 06:00:07 +0100
> > 
> > > On Mon, Jan 07, 2008 at 07:37:00PM -0800, David Miller wrote:
> > > > The vast majority of them are one, two, and three liners.
> > > 
> > > % awk '  { line++ } ; /^{/ { total++; start = line } ; /^}/ { len=line-start-3; if (len > 4) l++; if (len >= 10) k++; } ; END { print total, l, l/total, k, k/total }' < include/net/tcp.h
> > > 68 28 0.411765 20 0.294118
> > > 
> > > 41% are over 4 lines, 29% are >= 10 lines.
> > 
> > Take out the comments and whitespace lines, your script is
> > too simplistic.

In addition it triggered spuriously per struct/enum end brace :-) and
was using the last known function starting brace in there so no wonder
the numbers were that high... Counting with the corrected lines 
(len=line-start-1) & spurious matches removed:

74 19 0.256757 7 0.0945946


Here are (finally) the measured bytes (couple of the functions are 
missing because I had couple of bugs in the regexps and the #if trickery 
at the inline resulted failed compiles):

 12 funcs, 242+, 1697-, diff: -1455 	 tcp_set_state 
 13 funcs, 92+, 632-, diff: -540 	 tcp_is_cwnd_limited 
 12 funcs, 2836+, 3225-, diff: -389 	 tcp_current_ssthresh 
 5 funcs, 261+, 556-, diff: -295 	 tcp_prequeue 
 7 funcs, 2777+, 3049-, diff: -272 	 tcp_clear_retrans_hints_partial 
 11 funcs, 64+, 275-, diff: -211 	 tcp_win_from_space 
 6 funcs, 128+, 320-, diff: -192 	 tcp_prequeue_init 
 12 funcs, 45+, 209-, diff: -164 	 tcp_set_ca_state 
 7 funcs, 106+, 237-, diff: -131 	 tcp_fast_path_check 
 5 funcs, 167+, 291-, diff: -124 	 tcp_write_queue_purge 
 6 funcs, 43+, 160-, diff: -117 	 tcp_push_pending_frames 
 9 funcs, 55+, 159-, diff: -104 	 tcp_v4_check 
 6 funcs, 4+, 97-, diff: -93 	 tcp_packets_in_flight 
 7 funcs, 58+, 150-, diff: -92 	 tcp_fast_path_on 
 4 funcs, 4+, 91-, diff: -87 	 tcp_clear_options 
 6 funcs, 141+, 217-, diff: -76 	 tcp_openreq_init 
 8 funcs, 38+, 111-, diff: -73 	 tcp_unlink_write_queue 
 7 funcs, 32+, 103-, diff: -71 	 tcp_checksum_complete 
 7 funcs, 35+, 101-, diff: -66 	 __tcp_fast_path_on 
 5 funcs, 4+, 66-, diff: -62 	 tcp_receive_window 
 6 funcs, 67+, 128-, diff: -61 	 tcp_add_write_queue_tail 
 7 funcs, 30+, 86-, diff: -56 	 tcp_ca_event 
 6 funcs, 73+, 106-, diff: -33 	 tcp_paws_check 
 4 funcs, 4+, 36-, diff: -32 	 tcp_highest_sack_seq 
 6 funcs, 46+, 78-, diff: -32 	 tcp_fin_time 
 3 funcs, 4+, 35-, diff: -31 	 tcp_clear_all_retrans_hints 
 7 funcs, 30+, 51-, diff: -21 	 __tcp_add_write_queue_tail 
 3 funcs, 4+, 14-, diff: -10 	 tcp_enable_fack 
 4 funcs, 4+, 14-, diff: -10 	 keepalive_time_when 
 8 funcs, 66+, 73-, diff: -7 	 tcp_full_space 
 3 funcs, 4+, 5-, diff: -1 	 tcp_wnd_end 
 4 funcs, 97+, 97-, diff: +0 	 tcp_mib_init 
 3 funcs, 4+, 3-, diff: +1 	 tcp_skb_is_last 
 2 funcs, 4+, 2-, diff: +2 	 keepalive_intvl_when 
 2 funcs, 4+, 2-, diff: +2 	 tcp_is_fack 
 2 funcs, 4+, 2-, diff: +2 	 tcp_skb_mss 
 2 funcs, 4+, 2-, diff: +2 	 tcp_write_queue_empty 
 2 funcs, 4+, 2-, diff: +2 	 tcp_advance_highest_sack 
 2 funcs, 4+, 2-, diff: +2 	 tcp_advance_send_head 
 2 funcs, 4+, 2-, diff: +2 	 tcp_check_send_head 
 2 funcs, 4+, 2-, diff: +2 	 tcp_highest_sack_reset 
 2 funcs, 4+, 2-, diff: +2 	 tcp_init_send_head 
 2 funcs, 4+, 2-, diff: +2 	 tcp_sack_reset 
 6 funcs, 47+, 44-, diff: +3 	 tcp_space 
 5 funcs, 55+, 50-, diff: +5 	 tcp_too_many_orphans 
 3 funcs, 8+, 2-, diff: +6 	 tcp_minshall_update 
 3 funcs, 8+, 2-, diff: +6 	 tcp_update_wl 
 8 funcs, 25+, 14-, diff: +11 	 between 
 3 funcs, 14+, 2-, diff: +12 	 tcp_put_md5sig_pool 
 3 funcs, 14+, 2-, diff: +12 	 tcp_clear_xmit_timers 
 5 funcs, 30+, 17-, diff: +13 	 tcp_dec_pcount_approx_int 
 6 funcs, 33+, 20-, diff: +13 	 tcp_insert_write_queue_after 
 3 funcs, 17+, 2-, diff: +15 	 __tcp_checksum_complete 
 5 funcs, 17+, 2-, diff: +15 	 tcp_init_wl 
 4 funcs, 57+, 41-, diff: +16 	 tcp_dec_quickack_mode 
 4 funcs, 40+, 22-, diff: +18 	 __tcp_add_write_queue_head 
 5 funcs, 36+, 16-, diff: +20 	 tcp_highest_sack_combine 
 4 funcs, 40+, 18-, diff: +22 	 tcp_dec_pcount_approx 
 6 funcs, 29+, 5-, diff: +24 	 tcp_is_sack 
 4 funcs, 28+, 2-, diff: +26 	 tcp_is_reno 
 5 funcs, 50+, 24-, diff: +26 	 tcp_insert_write_queue_before 
 4 funcs, 83+, 56-, diff: +27 	 tcp_check_probe_timer 
 8 funcs, 69+, 14-, diff: +55 	 tcp_left_out 
 11 funcs, 2995+, 2893-, diff: +102 	 tcp_skb_pcount 
 30 funcs, 930+, 2-, diff: +928 	 before 

-- 
 i.
---696243703-154144947-1199909625=:3324--
