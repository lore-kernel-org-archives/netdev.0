From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Mon, 7 Jan 2008 09:13:22 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801070908001.17676@kivilampi-30.cs.helsinki.fi>
References: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
 <E1JBJOR-0000jO-00@gondolin.me.apana.org.au> <20080105.231658.168081302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	paul.moore@hp.com, latten@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46674 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbYAGHNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 02:13:24 -0500
In-Reply-To: <20080105.231658.168081302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 5 Jan 2008, David Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 06 Jan 2008 11:29:35 +1100
> 
> > We should never use inline except when it's on the fast path and this
> > is definitely not a fast path.  If a function ends up being called
> > just once the compiler will most likely inline it anyway, making the
> > use of the keyword inline redundant.
> 
> Similarly I question just about any inline usage at all in *.c files
> these days.
> 
> I even would discourage it's use for fast-path cases as well.

There still seems to be good candidates for inline in *.c files, in worst 
case I had +172 due to inline removed and ~60 are on +10-+90 range with 
my gcc, later gccs might do better but I definately would just blindly 
remove them all. Here's the other end of the list:

+35 static inline hci_encrypt_change_evt        net/bluetooth/hci_event.c
+36 static __inline__ tcp_in_window     net/ipv4/tcp_minisocks.c
+38 static inline hci_conn_complete_evt net/bluetooth/hci_event.c
+38 static inline hci_conn_request_evt  net/bluetooth/hci_event.c
+42 static inline gred_wred_mode        net/sched/sch_gred.c
+45 static inline secpath_has_nontransport      net/xfrm/xfrm_policy.c
+52 static inline bool port_match       net/netfilter/xt_tcpudp.c
+67 static inline dn_check_idf  net/decnet/dn_nsp_in.c
+90 static inline __ieee80211_queue_stopped     net/mac80211/tx.c
+172 static inline sctp_chunk_length_valid      net/sctp/sm_statefuns.c


-- 
 i.
