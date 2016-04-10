From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCHv2 net-next 1/6] sctp: add sctp_info dump api for sctp_diag
Date: Sun, 10 Apr 2016 09:02:27 -0400
Message-ID: <570A4EE3.9090302@mojatatu.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
 <1460178984.6473.473.camel@edumazet-glaptop3.roam.corp.google.com>
 <57091D90.4030905@mojatatu.com>
 <1460222507.6473.493.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34824 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcDJNCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 09:02:31 -0400
Received: by mail-oi0-f47.google.com with SMTP id p188so180718074oih.2
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 06:02:31 -0700 (PDT)
In-Reply-To: <1460222507.6473.493.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-09 01:21 PM, Eric Dumazet wrote:


> Well, once a hole is there, nothing we can do really, because of
> compatibility with old kernels / old binaries.
>
>
> But when a _new_ structure is defined, this is the time where we can ask
> for doing sensible things ;)
>

This one is fixable. sizeof() already includes the accounting of
the pad. something like:

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index fe95446..52542eb 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -158,6 +158,7 @@ struct tcp_info {
         __u8    tcpi_options;
         __u8    tcpi_snd_wscale : 4, tcpi_rcv_wscale : 4;

+       __u8    pad;    /*reuse this space if you need 8bits for something*/
         __u32   tcpi_rto;
         __u32   tcpi_ato;
         __u32   tcpi_snd_mss;

cheers,
jamal
