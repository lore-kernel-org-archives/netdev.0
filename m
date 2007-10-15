From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: kernel BUG at net/core/dev.c:1383 skb_checksum_help: BUG_ON(offset
 > (int)skb->len)
Date: Mon, 15 Oct 2007 13:54:42 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710151338570.3767@kivilampi-30.cs.helsinki.fi>
References: <20071006141506.785a6683@localhost.localdomain>
 <20071014192640.35065e73@inria.fr> <Pine.LNX.4.64.0710151251090.3767@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0710151311540.3767@kivilampi-30.cs.helsinki.fi>
 <20071015121829.15521102@inria.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-866227307-1192444831=:3767"
Cc: Netdev <netdev@vger.kernel.org>
To: Guillaume Chazarain <guichaz@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50121 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757932AbXJOKyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 06:54:45 -0400
In-Reply-To: <20071015121829.15521102@inria.fr>
Content-ID: <Pine.LNX.4.64.0710151345530.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-866227307-1192444831=:3767
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0710151340361.3767@kivilampi-30.cs.helsinki.fi>

On Mon, 15 Oct 2007, Guillaume Chazarain wrote:

> Le Mon, 15 Oct 2007 13:15:05 +0300 (EEST),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
>  
> > ...Never mind, noticed the fix later on.
> 
> Yes, but here is it anyway, in case you see something fishy.
>
> (gdb) p *(struct tcp_sock *)skb->sk
> $4 = {inet_conn = {icsk_inet = {sk = {__sk_common = {skc_family = 2, 

...snip...

>   mdev_max = 3080, rttvar = 3080, rtt_seq = 4014273285, packets_out = 16, 
>   retrans_out = 0, rx_opt = {ts_recent_stamp = 1192377268, 

...snip...

>   advmss = 1448, prior_ssthresh = 9, lost_out = 8, sacked_out = 8, 
>   fackets_out = 16, high_seq = 4014280275, retrans_stamp = 4946974, 
> 
> Thanks.

Hmm. Thanks.

Unlikely that there is something wrong. From values I counted that 
packets_out - (sacked_out + left_out) + retrans_out yields to zero,
so such large underflow is probably due to prior_inflight reused for 
something, though of course that particular state when prior_inflight
is collected is no longer available to us because tcp_clean_rtx_queue
was likely executed as packets_acked is 1. So I don't intend to do
further investigation on this one.

-- 
 i.
---696243703-866227307-1192444831=:3767--
