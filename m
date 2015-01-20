From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Tue, 20 Jan 2015 11:26:31 -0800
Message-ID: <1421781991.4832.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
	 <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
	 <54B590FB.5040805@dev.mellanox.co.il>
	 <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
	 <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54BC286B.8000605@mellanox.com>
	 <1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAA93jw42i37s5BJO5QJvFc=JnQBT5JsOX4QDxT6yKY3Ha3J3rg@mail.gmail.com>
	 <1421723651.17892.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54BEA91D.1050001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>, Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:52227 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbbATT0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 14:26:34 -0500
Received: by mail-ie0-f177.google.com with SMTP id at20so12172572iec.8
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 11:26:34 -0800 (PST)
In-Reply-To: <54BEA91D.1050001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-20 at 11:14 -0800, Rick Jones wrote:

> > Thats a 3 lines patch in netperf actually.
> 
> More stuff to pull from a TCP_INFO call I presume?  Feel free to drop me 
> a patch, though I'd probably want it to be in the guise of the omni 
> output selectors.
> 

It was something like :

diff --git a/src/nettest_omni.c b/src/nettest_omni.c
index fb2d5f4..80e43ca 100644
--- a/src/nettest_omni.c
+++ b/src/nettest_omni.c
@@ -3465,7 +3465,7 @@ static void
 dump_tcp_info(struct tcp_info *tcp_info)
 {
 
-  printf("tcpi_rto %d tcpi_ato %d tcpi_pmtu %d tcpi_rcv_ssthresh %d\n"
+  fprintf(stderr, "tcpi_rto %d tcpi_ato %d tcpi_pmtu %d tcpi_rcv_ssthresh %d\n"
         "tcpi_rtt %d tcpi_rttvar %d tcpi_snd_ssthresh %d tpci_snd_cwnd %d\n"
         "tcpi_reordering %d tcpi_total_retrans %d\n",
         tcp_info->tcpi_rto,
@@ -3539,7 +3539,7 @@ get_transport_retrans(SOCKET socket, int protocol) {
   }
   else {
 
-    if (debug > 1) {
+    if (debug > 1 || getenv("DUMP_TCP_INFO")) {
       dump_tcp_info(&tcp_info);
     }
     return tcp_info.tcpi_total_retrans;
