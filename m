From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN, Gigaset: Fix memory leak in do_disconnect_req()
Date: Fri, 31 Dec 2010 11:21:01 -0800 (PST)
Message-ID: <20101231.112101.70194518.davem@davemloft.net>
References: <alpine.LNX.2.00.1012262053130.20797@swampdragon.chaosbits.net>
	<4D1A2185.2010700@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jj@chaosbits.net, gigaset307x-common@lists.sourceforge.net,
	hjlipp@web.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D1A2185.2010700@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 28 Dec 2010 18:42:29 +0100

> Quite correct. Thanks for finding and fixing this.
> 
> Am 26.12.2010 20:59 schrieb Jesper Juhl:
>> Hi,
>> 
>> In drivers/isdn/gigaset/capi.c::do_disconnect_req() we will leak the 
>> memory allocated (with kmalloc) to 'b3cmsg' if the call to alloc_skb() 
>> fails.
>> 
>> ...
>> 		b3cmsg = kmalloc(sizeof(*b3cmsg), GFP_KERNEL);
>> 	allocation here ------^
>> 		if (!b3cmsg) {
>> 			dev_err(cs->dev, "%s: out of memory\n", __func__);
>> 			send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
>> 			return;
>> 		}
>> 		capi_cmsg_header(b3cmsg, ap->id, CAPI_DISCONNECT_B3, CAPI_IND,
>> 				 ap->nextMessageNumber++,
>> 				 cmsg->adr.adrPLCI | (1 << 16));
>> 		b3cmsg->Reason_B3 = CapiProtocolErrorLayer1;
>> 		b3skb = alloc_skb(CAPI_DISCONNECT_B3_IND_BASELEN, GFP_KERNEL);
>> 		if (b3skb == NULL) {
>> 			dev_err(cs->dev, "%s: out of memory\n", __func__);
>> 			send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
>> 			return;
>> 	leak here ------^
>> ...
>> 
>> This leak is easily fixed by just kfree()'ing the memory allocated to 
>> 'b3cmsg' right before we return. The following patch does that.
>> 
>> 
>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> 
> Acked-by: Tilman Schmidt <tilman@imap.cc>

Applied.
