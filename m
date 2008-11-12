From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 09:07:43 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
References: <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com>
 <20081111185036.GA17717@ioremap.net>
 <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com>
 <20081111192954.GA19409@ioremap.net>
 <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
 <20081112135828.GA30946@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>,
	Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:48166 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbYKLRHr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 12:07:47 -0500
In-Reply-To: <20081112135828.GA30946@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> -----Original Message-----
> From: Evgeniy Polyakov [mailto:zbr@ioremap.net]
> Sent: November-12-08 5:58 AM
> To: Johann Baudy
> Cc: Lovich, Vitali; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi.
> Hmm, for example splice() is supposed to do the same what you have, but
> because of udp_send*() limitations it can't. Splice does not care if
> data was overwritten during transfer, i.e. when ->sendpage() returns
> all
> code assumes that data has been successfully transmitted, so userspace
> can overwrite mapped area or file content, and this new data will
> actually be transmitted. I believe you can use the same model and do
> not
> care about userspace notifications after execution returned to the
> userspace from the 'sending call'.

I think you misunderstand how the API works.  Yes the user could call send from the thread he's filling in data from.  But the idea is that he would ideally do this from another thread so that it's possible to control latency between packet sends.  Additionally, even without trying to control latency, there would still have to be complicated logic in userspace to determine when enough packets have been placed in the buffer to overcome the cost of a system call.

This is why we need to know which frame in the ring buffer the skb is associated with.

Vitali
