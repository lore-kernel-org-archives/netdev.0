From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Mon, 8 Apr 2013 17:24:17 +0200
Message-ID: <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:48171 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936341Ab3DHP3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 11:29:21 -0400
Content-Disposition: inline
In-Reply-To: <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 08, 2013 at 08:40:10AM +0200, Erik Hugne wrote:
> Thanks Eric, it works as expected after applying this.

So, on to the next problem, now i'm getting corrupted packets
from the driver instead. Would be great to get some comments
from the Emulex guys regarding this.

Attaching a printk trace where i log the mac header and packet data of 
all 0x88CA (TIPC) packets in the gro_receive routine that have an 
erroneous TIPC header. This happens immediately when i register 
myself with the device.


kernel: [ 3455.608572] tipc: Activated (version 2.0.0)
kernel: [ 3455.609545] NET: Registered protocol family 30
kernel: [ 3455.609547] tipc: Started in single node mode
kernel: [ 3458.837149] tipc: Started in network mode
kernel: [ 3458.837153] tipc: Own node address <1.1.11>, network identity 4711
kernel: [ 3458.837244] tipc: Enabled bearer <eth:eth1>, discovery domain <1.1.0>, priority 10
kernel: [ 3458.837916] tipc: Garbage packet received
kernel: [ 3458.837919] tipc: packet length=56 data_len=56
kernel: [ 3458.837925] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.837929] pdata: 10 0b 00 00 00 01 9e dd 00 a0 01 00 10 0b 01 00 10 0a 00 00 00 00 01 77 05 dc 65 74 68 31 00 00  .......................w..eth1..
kernel: [ 3458.837933] pdata: 00 00 00 00 00 00 00 00 00 00 04 00 00 00 04 00 00 00 50 e5 74 64 5c e6                          ..................P.td\.
kernel: [ 3458.837942] tipc: Established link <1.1.11:eth1-1.1.10:eth1> on network plane A
kernel: [ 3458.838225] tipc: Garbage packet received
kernel: [ 3458.838228] tipc: packet length=56 data_len=56
kernel: [ 3458.838232] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.838236] pdata: 10 0b 00 00 00 01 9e dd 00 a1 01 00 10 0b 01 00 10 0a 00 00 00 00 00 00 00 00 65 74 68 31 00 00  ..........................eth1..
kernel: [ 3458.838239] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                          ........................
kernel: [ 3458.838244] tipc: Garbage packet received
kernel: [ 3458.838246] tipc: packet length=56 data_len=56
kernel: [ 3458.838249] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.838254] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00  ................................
kernel: [ 3458.838258] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                          ........................
kernel: [ 3458.838262] tipc: Garbage packet received
kernel: [ 3458.838263] tipc: packet length=60 data_len=60
kernel: [ 3458.838268] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.838272] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 72 65 65 64 65 73  ..........................reedes
kernel: [ 3458.838276] pdata: 6b 74 6f 70 2f 48 61 6c 2f 64 65 76 69 63 65 73 2f 6e 65 74 5f 65 34 5f 31 31 5f 35              ktop/Hal/devices/net_e4_11_5
kernel: [ 3459.976074] tipc: Garbage packet received
kernel: [ 3459.976077] tipc: packet length=56 data_len=56
kernel: [ 3459.976081] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3459.976085] pdata: 10 0b 00 00 00 03 9e dd 00 a1 01 00 10 0b 01 00 10 0a 00 00 00 00 00 00 00 00 65 74 68 31 00 00  ..........................eth1..
kernel: [ 3459.976089] pdata: 00 00 00 00 00 00 00 00 00 00 04 00 00 00 04 00 00 00 50 e5 74 64 5c e6                          ..................P.td\.
