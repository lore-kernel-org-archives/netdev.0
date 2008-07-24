From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 08:32:42 +0200
Message-ID: <20080724063242.GA9051@elte.hu>
References: <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721184616.GA8442@elte.hu> <20080722112133.GA6575@elte.hu> <4885E482.5020502@davidnewall.com> <20080722135723.GA23077@elte.hu> <4885F496.3010305@davidnewall.com> <20080722153443.GB18757@elte.hu> <20080722211256.GB29189@1wt.eu> <20080723082643.GA992@elte.hu> <20080724060448.GA10203@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Newall <davidn@davidnewall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:40313 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343AbYGXGd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 02:33:27 -0400
Content-Disposition: inline
In-Reply-To: <20080724060448.GA10203@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


here's a longer log from the server, with sequences, flags, etc:

08:06:47.809947 IP (tos 0x0, ttl 64, id 13998, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234555110:234555646(536) ack 2272574194 win 5840
08:06:47.809974 IP (tos 0x0, ttl 64, id 27389, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x9900 (correct), 2272574194:2272574194(0) ack 234555646 win 65535
08:06:47.810051 IP (tos 0x0, ttl 64, id 13999, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234620645:234621181(536) ack 2272574194 win 5840
08:06:47.810065 IP (tos 0x0, ttl 64, id 27390, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x9900 (correct), 2272574194:2272574194(0) ack 234555646 win 65535
08:08:47.829813 IP (tos 0x0, ttl 64, id 14000, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234555646:234556182(536) ack 2272574194 win 5840
08:08:47.829909 IP (tos 0x0, ttl 64, id 27391, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x96e8 (correct), 2272574194:2272574194(0) ack 234556182 win 65535
08:08:47.830009 IP (tos 0x0, ttl 64, id 14001, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234621181:234621717(536) ack 2272574194 win 5840
08:08:47.830026 IP (tos 0x0, ttl 64, id 27392, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x96e8 (correct), 2272574194:2272574194(0) ack 234556182 win 65535
08:10:47.849756 IP (tos 0x0, ttl 64, id 14002, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234556182:234556718(536) ack 2272574194 win 5840
08:10:47.849845 IP (tos 0x0, ttl 64, id 27393, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x94d0 (correct), 2272574194:2272574194(0) ack 234556718 win 65535
08:10:47.849936 IP (tos 0x0, ttl 64, id 14003, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234621717:234622253(536) ack 2272574194 win 5840
08:10:47.849951 IP (tos 0x0, ttl 64, id 27394, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x94d0 (correct), 2272574194:2272574194(0) ack 234556718 win 65535
08:12:47.870018 IP (tos 0x0, ttl 64, id 14004, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234556718:234557254(536) ack 2272574194 win 5840
08:12:47.870091 IP (tos 0x0, ttl 64, id 27395, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x92b8 (correct), 2272574194:2272574194(0) ack 234557254 win 65535
08:12:47.870217 IP (tos 0x0, ttl 64, id 14005, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234622253:234622789(536) ack 2272574194 win 5840
08:12:47.870266 IP (tos 0x0, ttl 64, id 27396, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x92b8 (correct), 2272574194:2272574194(0) ack 234557254 win 65535
08:14:47.889925 IP (tos 0x0, ttl 64, id 14006, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234557254:234557790(536) ack 2272574194 win 5840
08:14:47.890006 IP (tos 0x0, ttl 64, id 27397, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x90a0 (correct), 2272574194:2272574194(0) ack 234557790 win 65535
08:14:47.890105 IP (tos 0x0, ttl 64, id 14007, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234622789:234623325(536) ack 2272574194 win 5840
08:14:47.890120 IP (tos 0x0, ttl 64, id 27398, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x90a0 (correct), 2272574194:2272574194(0) ack 234557790 win 65535
08:16:47.909483 IP (tos 0x0, ttl 64, id 14008, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234557790:234558326(536) ack 2272574194 win 5840
08:16:47.909583 IP (tos 0x0, ttl 64, id 27399, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8e88 (correct), 2272574194:2272574194(0) ack 234558326 win 65535
08:16:47.909700 IP (tos 0x0, ttl 64, id 14009, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234623325:234623861(536) ack 2272574194 win 5840
08:16:47.909717 IP (tos 0x0, ttl 64, id 27400, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8e88 (correct), 2272574194:2272574194(0) ack 234558326 win 65535
08:18:47.929372 IP (tos 0x0, ttl 64, id 14010, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234558326:234558862(536) ack 2272574194 win 5840
08:18:47.929428 IP (tos 0x0, ttl 64, id 27401, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8c70 (correct), 2272574194:2272574194(0) ack 234558862 win 65535
08:18:47.929506 IP (tos 0x0, ttl 64, id 14011, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234623861:234624397(536) ack 2272574194 win 5840
08:18:47.929519 IP (tos 0x0, ttl 64, id 27402, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8c70 (correct), 2272574194:2272574194(0) ack 234558862 win 65535
08:20:47.949661 IP (tos 0x0, ttl 64, id 14012, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234558862:234559398(536) ack 2272574194 win 5840
08:20:47.949761 IP (tos 0x0, ttl 64, id 27403, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8a58 (correct), 2272574194:2272574194(0) ack 234559398 win 65535
08:20:47.949867 IP (tos 0x0, ttl 64, id 14013, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234624397:234624933(536) ack 2272574194 win 5840
08:20:47.949884 IP (tos 0x0, ttl 64, id 27404, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8a58 (correct), 2272574194:2272574194(0) ack 234559398 win 65535
08:22:47.969196 IP (tos 0x0, ttl 64, id 14014, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234559398:234559934(536) ack 2272574194 win 5840
08:22:47.969291 IP (tos 0x0, ttl 64, id 27405, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8840 (correct), 2272574194:2272574194(0) ack 234559934 win 65535
08:22:47.969372 IP (tos 0x0, ttl 64, id 14015, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234624933:234625469(536) ack 2272574194 win 5840
08:22:47.969433 IP (tos 0x0, ttl 64, id 27406, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8840 (correct), 2272574194:2272574194(0) ack 234559934 win 65535
08:24:47.989458 IP (tos 0x0, ttl 64, id 14016, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234559934:234560470(536) ack 2272574194 win 5840
08:24:47.989518 IP (tos 0x0, ttl 64, id 27407, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8628 (correct), 2272574194:2272574194(0) ack 234560470 win 65535
08:24:47.989642 IP (tos 0x0, ttl 64, id 14017, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234625469:234626005(536) ack 2272574194 win 5840
08:24:47.989655 IP (tos 0x0, ttl 64, id 27408, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8628 (correct), 2272574194:2272574194(0) ack 234560470 win 65535
08:26:48.009355 IP (tos 0x0, ttl 64, id 14018, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234560470:234561006(536) ack 2272574194 win 5840
08:26:48.009432 IP (tos 0x0, ttl 64, id 27409, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8410 (correct), 2272574194:2272574194(0) ack 234561006 win 65535
08:26:48.009523 IP (tos 0x0, ttl 64, id 14019, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234626005:234626541(536) ack 2272574194 win 5840
08:26:48.009539 IP (tos 0x0, ttl 64, id 27410, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8410 (correct), 2272574194:2272574194(0) ack 234561006 win 65535
08:28:48.028909 IP (tos 0x0, ttl 64, id 14020, offset 0, flags [DF], proto TCP (6), length 290) dione.39201 > phoenix.distcc: . 234561006:234561256(250) ack 2272574194 win 5840
08:28:48.028961 IP (tos 0x0, ttl 64, id 27411, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8316 (correct), 2272574194:2272574194(0) ack 234561256 win 65535
08:28:48.029044 IP (tos 0x0, ttl 64, id 14021, offset 0, flags [DF], proto TCP (6), length 147) dione.39201 > phoenix.distcc: P 234626541:234626648(107) ack 2272574194 win 5840
08:28:48.029057 IP (tos 0x0, ttl 64, id 27412, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8316 (correct), 2272574194:2272574194(0) ack 234561256 win 65535
08:30:48.049167 IP (tos 0x0, ttl 64, id 14022, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234561256:234561792(536) ack 2272574194 win 5840
08:30:48.049223 IP (tos 0x0, ttl 64, id 27413, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
08:30:48.049341 IP (tos 0x0, ttl 64, id 14023, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234626648:234627184(536) ack 2272574194 win 5840
08:30:48.049348 IP (tos 0x0, ttl 64, id 14024, offset 0, flags [DF], proto TCP (6), length 183) dione.39201 > phoenix.distcc: . 234627184:234627327(143) ack 2272574194 win 5840
08:30:48.049354 IP (tos 0x0, ttl 64, id 27414, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
08:30:48.049359 IP (tos 0x0, ttl 64, id 27415, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
