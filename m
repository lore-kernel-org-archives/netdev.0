From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: TCP hangs --- zero window probes
Date: Tue, 4 May 2004 16:26:13 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405041617470.3979@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

This is tcpdump of hung TCP connection (from paranoia.kolej.mff.cuni.cz's
point of view). It looks like Linux did misbehave.

213.29.7.213 is a Linux box. (don't know which version, I have no access
to it).
paranoia.kolej.mff.cuni.cz is stack that I wrote myself.

Linux is sending only ACKs without any data as zero-window probes. My
stack ignores them. People at IETF tcp mailing lists told me that it's
linux bug, that window probe must contain some new data.

Is it known bug in Linux? What workaround do you suggest?

Mikulas

16:34:49.832097 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: SWE 1711254266:1711254266(0) win 8192 <mss 1460,sackOK,wscale 10,eol>
16:34:49.838957 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: S 1163781419:1163781419(0) ack 1711254267 win 5840 <mss 1460,nop,nop,sackOK,nop,wscale 0>
16:34:49.838968 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 1 win 8
16:34:49.840002 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P 1:500(499) ack 1 win 8
16:34:49.847349 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
16:34:49.863592 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 1:1461(1460) ack 500 win 6432
16:34:49.863651 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 1461 win 6
16:34:49.867490 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 1461:2921(1460) ack 500 win 6432
16:34:49.867558 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 2921 win 6
16:34:49.871498 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 2921:4381(1460) ack 500 win 6432
16:34:49.871567 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 4381 win 5
16:34:49.872729 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 4381:5841(1460) ack 500 win 6432
16:34:49.872777 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 5841 win 3
16:34:49.875631 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 7301:8761(1460) ack 500 win 6432
16:34:49.875714 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 5841 win 3 <nop,nop,sack sack 1 {7301:8761} >
16:34:49.876881 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 5841:7301(1460) ack 500 win 6432
16:34:49.876953 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 8761 win 0
16:34:49.907290 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: P ack 8761 win 2
^^^^ this packet was probably lost or the last two were reordered
16:34:50.088544 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
16:34:50.512936 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
^^^ this looks to me like a bug --- window probe doesn't contain data
16:34:51.348911 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
16:34:53.028754 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
16:34:56.389624 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
16:35:03.110512 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
^^^ exponential backoff on window probes is fine, except that the packets are pure acks
16:35:16.552095 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
16:35:43.435482 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . ack 500 win 6432
16:35:58.706896 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: FP 500:500(0) ack 8761 win 17
^^^ paranoia closed the connection without receiving any data
16:35:58.717487 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 10221:11681(1460) ack 501 win 6432
16:35:58.717569 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: R 501:501(0) ack 11681 win 0
16:35:58.718673 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 8761:10221(1460) ack 501 win 6432
16:35:58.718692 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: R 501:501(0) ack 10221 win 0
16:35:58.720054 IP 213.29.7.213.http > paranoia.kolej.mff.cuni.cz.65461: . 11681:13141(1460) ack 501 win 6432
16:35:58.720074 IP paranoia.kolej.mff.cuni.cz.65461 > 213.29.7.213.http: R 501:501(0) ack 13141 win 0
