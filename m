From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev <device_name> ' command
Date: Thu, 17 Dec 2015 12:45:33 +0300
Message-ID: <907481450345533@web24h.yandex.ru>
References: <5917221449918579@web5j.yandex.ru> <20151216161558.265296c7@redhat.com> <740111450344461@web24h.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Phil Sutter <psutter@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward11h.cmail.yandex.net ([87.250.230.153]:33711 "EHLO
	forward11h.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403AbbLQJpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 04:45:38 -0500
In-Reply-To: <740111450344461@web24h.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper,

Sorry, it seems that I accidentally sent out an unfinished e-mail.

>I don't think your patch should contain this cleanup of "b4".

It seems that b3 is only used for the legacy overhead part and if I remove it, b3 is not going to be used. So I figured I remove b4 put b3 instead.

administrator@ubuntu:~/src/iproute2/tc$ git rev-parse HEAD
654ae881de57467642c8c2ed16ffc3a8d57fafa2

administrator@ubuntu:~/src/iproute2/tc$ grep -nHP -B 3 'b3' q_htb.c
q_htb.c-273-	__u64 rate64, ceil64;
q_htb.c-274-	SPRINT_BUF(b1);
q_htb.c-275-	SPRINT_BUF(b2);
q_htb.c:276:	SPRINT_BUF(b3);
--
q_htb.c-317-				sprint_size(buffer, b1),
q_htb.c-318-				1<<hopt->rate.cell_log,
q_htb.c-319-				sprint_size(hopt->rate.mpu&0xFF, b2),
q_htb.c:320:				sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
--
q_htb.c-322-				sprint_size(cbuffer, b1),
q_htb.c-323-				1<<hopt->ceil.cell_log,
q_htb.c-324-				sprint_size(hopt->ceil.mpu&0xFF, b2),
q_htb.c:325:				sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));
administrator@ubuntu:~/src/iproute2/tc$ grep -nHP -B 3 'b4' q_htb.c
q_htb.c-274-	SPRINT_BUF(b1);
q_htb.c-275-	SPRINT_BUF(b2);
q_htb.c-276-	SPRINT_BUF(b3);
q_htb.c:277:	SPRINT_BUF(b4);
--
q_htb.c-311-		cbuffer = tc_calc_xmitsize(ceil64, hopt->cbuffer);
q_htb.c-312-		linklayer = (hopt->rate.linklayer & TC_LINKLAYER_MASK);
q_htb.c-313-		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
q_htb.c:314:			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));

Thanks,
Dima
