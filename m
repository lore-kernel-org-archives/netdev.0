From: Yong Zhang <fell198904@gmail.com>
Subject: The ssthresh reduce during 3WHS
Date: Wed, 12 Mar 2014 21:46:04 +0800
Message-ID: <CAH4NVoT4ofCNKAmcnO1AgEbs+ywbXom=E28k2VU4dB+yK79S_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yong Zhang <fell198904@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f193.google.com ([209.85.128.193]:63675 "EHLO
	mail-ve0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620AbaCLNqF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 09:46:05 -0400
Received: by mail-ve0-f193.google.com with SMTP id oz11so3767067veb.0
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 06:46:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi=EF=BC=8C

I am trying to to apply patch 9ad7c049f0f79c418e293b1b68cf10d68f54fcdb
to my old version kernel, but I am not understanding the following
changes.

The comments int the patch say ssthresh may reduce unnecessarily
druing 3WHS,  but i can not find the reduce operation of ssthresh
during 3WHS.

Can you please explain when dose this may hanppen?


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bef9f04..ea0d218 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -880,6 +880,11 @@ static void tcp_init_metrics(struct sock *sk)

        tp->snd_ssthresh =3D dst_metric(dst, RTAX_SSTHRESH);
                 if (tp->snd_ssthresh > tp->snd_cwnd_clamp)
                         tp->snd_ssthresh =3D tp->snd_cwnd_clamp;
+       } else {
+                /* ssthresh may have been reduced unnecessarily during=
=2E
+                * 3WHS. Restore it back to its initial default.
+                */
+                tp->snd_ssthresh =3D TCP_INFINITE_SSTHRESH;
         }


Thanks,
=46el
