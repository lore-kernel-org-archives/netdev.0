From: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero window
 is advertised
Date: Tue, 16 Sep 2014 16:47:12 +0400
Message-ID: <54183150.5030400@oktetlabs.ru>
References: <54170FC0.6020907@oktetlabs.ru> <1410822949.5018.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([84.52.89.53]:45694 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbaIPMrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 08:47:20 -0400
In-Reply-To: <1410822949.5018.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/14 03:15, Hannes Frederic Sowa wrote:
> Also thanks for the report.
>
> Do you see any tcp window repair messages in dmesg? Can you send some
> output of ss -oemit state FIN-WAIT-1 from the target host?
Hannes,
no, there aren't any messages in dmesg until net.ipv4.tcp_max_orphans is 
achieved.

# ss -oemit state FIN-WAIT-1
0 1 10.0.5.2:http 10.0.5.1:35973    timer:(persist,23sec,0) ino:0 
sk:ffff880226756140 ---
      skmem:(r0,rb374400,t0,tb46080,f4294966016,w1280,o0,bl0) cubic 
mss:536 cwnd:10 retrans:0/1 rcv_space:29200
0 1 10.0.5.2:http 10.0.5.1:35320    timer:(persist,26sec,0) ino:0 
sk:ffff88020b5cf180 ---
      skmem:(r0,rb374400,t0,tb46080,f4294966016,w1280,o0,bl0) cubic 
rto:2964 rtt:988/494 mss:536 cwnd:10 send 43.4Kbps rcv_space:29200
0 1 10.0.5.2:http 10.0.5.1:56784    timer:(persist,20sec,0) ino:0 
sk:ffff88022543e800 ---
      skmem:(r0,rb374400,t0,tb46080,f4294966016,w1280,o0,bl0) cubic 
rto:2964 rtt:988/494 mss:536 cwnd:10 send 43.4Kbps rcv_space:29200
0 1 10.0.5.2:http 10.0.5.1:45866    timer:(persist,22sec,0) ino:0 
sk:ffff88020b9d3140 ---
      skmem:(r0,rb374400,t0,tb46080,f4294966016,w1280,o0,bl0) cubic 
rto:2952 rtt:984/492 mss:536 cwnd:10 send 43.6Kbps rcv_space:29200

Thanks,
Andrey
