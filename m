From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have
 a TCP_TIMEWAIT sk
Date: Sat, 4 Jul 2015 10:40:59 +0200
Message-ID: <CANn89iJsqGUcSptWHJXYDmfO4XQZbb7nxVdjhuwcN3fVLcvEyg@mail.gmail.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
	<20150701.141402.587634025761326092.davem@davemloft.net>
	<CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
	<CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
	<CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
	<CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com>
	<alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg>
	<CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
	<CALCkm3eGTi6038Zq7N+XZsX3v5vbP0wY42ded0YUbBn0pjSE8Q@mail.gmail.com>
	<alpine.LFD.2.11.1507031131010.1649@ja.home.ssi.bg>
	<CALCkm3eCnC7fwtStGZj4xZDJeNegLT3vBHKNABvsEq7_H7aQfg@mail.gmail.com>
	<alpine.LFD.2.11.1507041100480.1484@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Gartrell <alexgartrell@gmail.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38056 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbbGEJsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 05:48:45 -0400
Received: by wibdq8 with SMTP id dq8so129731974wib.1
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 02:48:44 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1507041100480.1484@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         Looks like routing by definition can not divert skbs with
> early-demux socket because input routing is not called.

Only if found socket has a valid sk->sk_rx_dst

Early demux :

1) if TCP lookup found a matching socket, we do the attachment
   skb->sk = sk;
   skb->destructor = sock_edemux

2) If sk->sk_rx_dst is set and still valid, IP routing will use this cached dst.

So it looks very possible that some packets could match a socket but
fail the 2) phase.
