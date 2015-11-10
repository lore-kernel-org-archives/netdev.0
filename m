From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: network stream fairness
Date: Tue, 10 Nov 2015 10:38:44 +0100
Message-ID: <5641BB24.4060301@axis.com>
References: <5640BEAC.10404@axis.com>	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <5640C15E.805@axis.com>	 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <1447086271.17135.45.camel@edumazet-glaptop2.roam.corp.google.com>	 <5640CED5.6040103@axis.com> <1447089782.17135.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:53996 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbbKJJiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2015 04:38:51 -0500
In-Reply-To: <1447089782.17135.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2015 06:23 PM, Eric Dumazet wrote:
> On Mon, 2015-11-09 at 17:50 +0100, Niklas Cassel wrote:
> 
>>
>> for i in `seq 1 20`; do ss -temoi dst 192.168.0.141; sleep 1; done
> ...
>> ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
>> State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
>> ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
>> ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
>> ESTAB      1448   0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
> 
> This is the receiver, I would like to see the sender side, since the
> changes we talk about are at his side, of course.

Sorry for that.

iperf3 sample. most samples were equal to this.
[  4]  10.00-11.00  sec  3.75 MBytes  31.5 Mbits/sec
[  6]  10.00-11.00  sec  7.05 MBytes  59.2 Mbits/sec
[SUM]  10.00-11.00  sec  10.8 MBytes  90.7 Mbits/sec


# for i in `seq 1 20`; do ./ss -temoi dst 192.168.0.1; sleep 1; done
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t0,tb44800,f20480,w0,o0,bl0) ts sack cubic wscale:7,5 rto:200 ato:40 mss:1448 cwnd:10 bytes_received:37 segs_out:1 segs_in:1 rcv_space:28960
ESTAB      0      1       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 timer:(on,210ms,0) ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f1856,w2240,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:0.03/0.06 ato:40 mss:1448 cwnd:10 bytes_acked:1 bytes_received:143 segs_out:5 segs_in:4 send 3861.3Mbps lastack:40 pacing_rate 7690.6Mbps unacked:1 rcv_space:28960
ESTAB      37     0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 ino:0 sk:6 <->
	 skmem:(r16576,rb328320,t0,tb44800,f3904,w0,o0,bl0) ts sack cubic wscale:7,5 rto:200 ato:40 mss:1448 cwnd:10 bytes_received:37 segs_out:1 segs_in:1 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      159280  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t27472,tb192640,f120048,w162576,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.326/0.789 ato:40 mss:1448 cwnd:43 ssthresh:16 bytes_acked:4500384 bytes_received:37 segs_out:3126 segs_in:1586 send 93.5Mbps lastsnd:10 lastrcv:1040 pacing_rate 112.2Mbps unacked:17 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:940 lastrcv:1040 lastack:940 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      273672  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,200ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t55576,tb277760,f44024,w279560,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:4.578/0.644 ato:40 mss:1448 cwnd:62 ssthresh:19 bytes_acked:6114904 bytes_received:37 segs_out:4261 segs_in:2147 send 156.9Mbps lastsnd:10 lastrcv:1040 lastack:10 pacing_rate 188.2Mbps unacked:37 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      136112  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t15776,tb201600,f142512,w140112,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:6.518/1.397 ato:40 mss:1448 cwnd:45 ssthresh:16 bytes_acked:8954432 bytes_received:37 segs_out:6196 segs_in:3124 send 80.0Mbps lastsnd:10 lastrcv:2090 pacing_rate 96.0Mbps unacked:11 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:1990 lastrcv:2090 lastack:1990 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      360552  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t31112,tb344960,f48776,w364920,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.294/0.545 ato:40 mss:1448 cwnd:77 ssthresh:19 bytes_acked:13586584 bytes_received:37 segs_out:9405 segs_in:4727 send 168.5Mbps lastsnd:10 lastrcv:2090 pacing_rate 202.2Mbps unacked:21 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      141904  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t25168,tb201600,f136720,w145904,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.163/0.728 ato:40 mss:1448 cwnd:45 ssthresh:16 bytes_acked:12727920 bytes_received:37 segs_out:8806 segs_in:4427 send 72.8Mbps lastrcv:3130 pacing_rate 87.3Mbps unacked:15 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:3030 lastrcv:3130 lastack:3030 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      295392  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t32560,tb362880,f146704,w299760,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.195/1.377 ato:40 mss:1448 cwnd:81 ssthresh:19 bytes_acked:21666424 bytes_received:37 segs_out:14987 segs_in:7517 send 180.6Mbps lastrcv:3130 pacing_rate 216.7Mbps unacked:23 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      222992  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t20936,tb201600,f55040,w227584,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.367/2.105 ato:40 mss:1448 cwnd:45 ssthresh:16 bytes_acked:16295792 bytes_received:37 segs_out:11268 segs_in:5659 send 70.8Mbps lastrcv:4170 pacing_rate 84.9Mbps unacked:13 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:4070 lastrcv:4170 lastack:4070 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      422816  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t55576,tb421120,f66432,w429184,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:6.213/1.45 ato:40 mss:1448 cwnd:94 ssthresh:19 bytes_acked:29879480 bytes_received:37 segs_out:20671 segs_in:10353 send 175.3Mbps lastrcv:4170 pacing_rate 210.3Mbps unacked:35 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      156384  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t20936,tb201600,f122240,w160384,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.188/2.283 ato:40 mss:1448 cwnd:45 ssthresh:16 bytes_acked:19620400 bytes_received:37 segs_out:13564 segs_in:6807 send 72.5Mbps lastrcv:5230 pacing_rate 87.0Mbps unacked:13 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:5130 lastrcv:5230 lastack:5130 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      403992  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t92480,tb443520,f105032,w411064,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.042/0.588 ato:40 mss:1448 cwnd:99 ssthresh:19 bytes_acked:38564584 bytes_received:37 segs_out:26688 segs_in:13352 send 227.5Mbps lastrcv:5230 pacing_rate 272.9Mbps unacked:54 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      217200  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t20232,tb201600,f61536,w221088,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:6.221/0.969 ato:40 mss:1448 cwnd:45 ssthresh:16 bytes_acked:22947904 bytes_received:37 segs_out:15862 segs_in:7956 send 83.8Mbps lastrcv:6270 pacing_rate 100.5Mbps unacked:13 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:6170 lastrcv:6270 lastack:6170 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      338832  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t70056,tb443520,f167968,w348128,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:6.561/1.376 ato:40 mss:1448 cwnd:99 ssthresh:19 bytes_acked:47035384 bytes_received:37 segs_out:32515 segs_in:16277 send 174.8Mbps lastrcv:6270 pacing_rate 209.7Mbps unacked:31 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      165072  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,200ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t23088,tb201600,f112144,w170480,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.989/1.849 ato:40 mss:1448 cwnd:45 ssthresh:16 bytes_acked:26258032 bytes_received:37 segs_out:18149 segs_in:9099 send 65.2Mbps lastsnd:10 lastrcv:7320 lastack:10 pacing_rate 78.3Mbps unacked:14 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:7220 lastrcv:7320 lastack:7220 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      375784  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t78744,tb443520,f133160,w382936,o0,bl198912) ts sack cubic wscale:7,5 rto:210 rtt:4.957/1.656 ato:40 mss:1448 cwnd:99 ssthresh:19 bytes_acked:55535144 bytes_received:37 segs_out:38415 segs_in:19222 send 231.4Mbps lastrcv:7320 pacing_rate 277.6Mbps unacked:61 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      247608  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t30368,tb313600,f128136,w252792,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.656/0.514 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:29498656 bytes_received:37 segs_out:20394 segs_in:10218 send 105.9Mbps lastrcv:8360 pacing_rate 127.1Mbps unacked:21 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:8260 lastrcv:8360 lastack:8260 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      677664  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t81640,tb663040,f47488,w685696,o0,bl66304) ts sack cubic wscale:7,5 rto:210 rtt:6.851/1.229 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:64159432 bytes_received:37 segs_out:44357 segs_in:22193 send 250.2Mbps lastrcv:8360 pacing_rate 310.5Mbps unacked:47 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      249056  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t28176,tb313600,f125984,w254944,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:8.744/0.863 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:33406808 bytes_received:37 segs_out:23091 segs_in:11567 send 92.7Mbps lastrcv:9400 pacing_rate 111.3Mbps unacked:19 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:9300 lastrcv:9400 lastack:9300 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      464808  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t65008,tb663040,f262120,w471064,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.134/0.497 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:72061168 bytes_received:37 segs_out:49795 segs_in:24945 send 240.3Mbps lastsnd:10 lastrcv:9410 pacing_rate 288.4Mbps unacked:28 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      288152  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t15184,tb313600,f86888,w294040,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:9.285/1.307 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:37212152 bytes_received:37 segs_out:25710 segs_in:12881 send 87.3Mbps lastrcv:10450 pacing_rate 104.8Mbps unacked:10 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:10350 lastrcv:10450 lastack:10350 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      564720  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t51272,tb663040,f162432,w570752,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:8.322/1.752 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:80106256 bytes_received:37 segs_out:55343 segs_in:27723 send 206.0Mbps lastsnd:10 lastrcv:10450 pacing_rate 247.2Mbps unacked:20 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      267880  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t35304,tb313600,f107864,w273064,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:8.76/0.731 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:41011704 bytes_received:37 segs_out:28347 segs_in:14193 send 92.6Mbps lastrcv:11490 pacing_rate 111.1Mbps unacked:23 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:11390 lastrcv:11490 lastack:11390 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      486528  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t88880,tb663040,f240400,w492784,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.538/0.738 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:88133968 bytes_received:37 segs_out:60921 segs_in:30495 send 309.6Mbps lastrcv:11490 pacing_rate 371.4Mbps unacked:54 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      298288  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t33264,tb313600,f77456,w303472,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.306/0.724 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:45347016 bytes_received:37 segs_out:31341 segs_in:15707 send 152.8Mbps lastrcv:12540 pacing_rate 183.4Mbps unacked:23 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:12440 lastrcv:12540 lastack:12440 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      435848  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t65008,tb663040,f291784,w441400,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.295/0.793 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:95678048 bytes_received:37 segs_out:66107 segs_in:33100 send 323.8Mbps lastrcv:12540 pacing_rate 388.5Mbps unacked:30 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      272224  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t42544,tb313600,f103520,w277408,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.634/0.526 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:49413000 bytes_received:37 segs_out:34154 segs_in:17111 send 106.2Mbps lastrcv:13590 pacing_rate 127.5Mbps unacked:28 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:13490 lastrcv:13590 lastack:13490 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      637120  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t100352,tb663040,f87328,w645856,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:6.989/0.565 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:103491456 bytes_received:37 segs_out:71531 segs_in:35798 send 245.3Mbps lastrcv:13590 pacing_rate 294.3Mbps unacked:58 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      249056  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t47000,tb313600,f126688,w254240,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.486/1.174 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:53345768 bytes_received:37 segs_out:36874 segs_in:18469 send 147.8Mbps lastrcv:14630 pacing_rate 177.3Mbps unacked:32 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:14530 lastrcv:14630 lastack:14530 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      525624  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t70800,tb663040,f201416,w531768,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:5.716/0.694 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:111356992 bytes_received:37 segs_out:76933 segs_in:38514 send 299.9Mbps lastrcv:14630 pacing_rate 359.9Mbps unacked:28 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      267880  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t31664,tb313600,f106456,w274472,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:9.387/1.297 ato:40 mss:1448 cwnd:70 ssthresh:16 bytes_acked:57432024 bytes_received:37 segs_out:39685 segs_in:19880 send 86.4Mbps lastrcv:15670 pacing_rate 103.7Mbps unacked:21 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:15570 lastrcv:15670 lastack:15570 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      553136  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,220ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t45480,tb663040,f174016,w559168,o0,bl0) ts sack cubic wscale:7,5 rto:220 rtt:10.243/1.677 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:119083520 bytes_received:37 segs_out:82249 segs_in:41182 send 167.4Mbps lastsnd:10 lastrcv:15670 pacing_rate 200.8Mbps unacked:8 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      330144  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,210ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t43992,tb461440,f171984,w335920,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:9.143/1.799 ato:40 mss:1448 cwnd:103 ssthresh:16 bytes_acked:61605160 bytes_received:37 segs_out:42575 segs_in:21321 send 130.5Mbps lastrcv:16730 pacing_rate 156.6Mbps unacked:29 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:16630 lastrcv:16730 lastack:16630 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      641464  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,210ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t52720,tb663040,f85096,w648088,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.014/1.233 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:126879552 bytes_received:37 segs_out:87654 segs_in:43875 send 244.4Mbps lastsnd:10 lastrcv:16730 pacing_rate 293.3Mbps unacked:29 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      376480  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,200ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t34712,tb461440,f125760,w382144,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.648/0.774 ato:40 mss:1448 cwnd:103 ssthresh:16 bytes_acked:66510984 bytes_received:37 segs_out:45958 segs_in:23015 send 156.0Mbps lastsnd:10 lastrcv:17770 lastack:10 pacing_rate 187.2Mbps unacked:24 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:17670 lastrcv:17770 lastack:17670 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      682008  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,220ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t45480,tb663040,f43256,w689928,o0,bl0) ts sack cubic wscale:7,5 rto:220 rtt:13.254/1.111 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:133745968 bytes_received:37 segs_out:92374 segs_in:46245 send 129.4Mbps lastsnd:20 lastrcv:17770 pacing_rate 155.2Mbps unacked:7 rcv_space:28960
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
ESTAB      0      372136  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55404                 timer:(on,200ms,0) ino:17349 sk:4 <->
	 skmem:(r0,rb328320,t26768,tb461440,f130104,w377800,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:7.694/0.761 ato:40 mss:1448 cwnd:103 ssthresh:16 bytes_acked:71402328 bytes_received:37 segs_out:49331 segs_in:24704 send 155.1Mbps lastsnd:10 lastrcv:18810 lastack:10 pacing_rate 186.1Mbps unacked:19 rcv_space:28960
ESTAB      0      0       ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55402                 ino:18856 sk:5 <->
	 skmem:(r0,rb328320,t0,tb44800,f0,w0,o0,bl0) ts sack cubic wscale:7,5 rto:210 rtt:3.738/6.898 ato:40 mss:1448 cwnd:10 bytes_acked:4 bytes_received:143 segs_out:7 segs_in:7 send 31.0Mbps lastsnd:18710 lastrcv:18810 lastack:18710 pacing_rate 62.0Mbps rcv_space:28960
ESTAB      0      556032  ::ffff:192.168.0.143:5201                    ::ffff:192.168.0.1:55406                 timer:(on,200ms,0) ino:17351 sk:6 <->
	 skmem:(r0,rb328320,t38944,tb663040,f168896,w564288,o0,bl149184) ts sack cubic wscale:7,5 rto:210 rtt:8.519/1.818 ato:40 mss:1448 cwnd:148 ssthresh:19 bytes_acked:140583424 bytes_received:37 segs_out:97134 segs_in:48615 send 201.2Mbps lastsnd:10 lastrcv:18810 lastack:10 pacing_rate 241.5Mbps unacked:45 rcv_space:28960
