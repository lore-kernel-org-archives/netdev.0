From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: refactoring cdc_ncm
Date: Sun, 28 Dec 2014 15:53:13 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412281540440.18200@gmail.com>
References: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com> <877fy7myfb.fsf@nemi.mork.no> <alpine.LNX.2.03.1412041326160.9926@gmail.com> <54811670.5030703@audiocodes.com> <8761dqjuuh.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:45741 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbaL1OxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 09:53:19 -0500
In-Reply-To: <8761dqjuuh.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone, hello Bjorn.
Sorry for my prevous private mail, didn't think about it.

So I was wondering how it could be possible to refactor the cdc_ncm.c driver to 
queue frames and only when enough data was collected, generate a full NCM 
packet.

so I am trying to get clear what's the way to go.
My idea was to try to not change the layout of the code so much: I would like 
not breaking cdc_mbim.c and other code sharing some of these functions, so all 
of the work would be done in the cdc_ncm_fill_tx_frame function.

Before starting with code, I would like to organize ideas:
- when an SKB comes in, if the queue isn't empty, I would queue it
   Somethink like
   if (skb_queue_empty(ctx->skb_tx_queue)){
     skb_insert(skb);
   } else {
     ready2send=1;
   }
- at this point, performs some check to see if we have enough data:how can I do
   so? What should I check? Sizes of nth16 + ntb16 + ... ?

   - if not enough data is present, exit the function returning NULL
   else
   - invoke some functions to prepare the NCM packet

I plan to move / rewrite the needed code to isolate it completely from the 
queue logic: making it also a little bit more clear. I would like to have 
separate functions for any parts of the NCM packet construction.
This would allow better flexibility and probably less maintenance burden in the 
long run, and might open the road to extending the driver to support 32-bit NCM 
and different signness handling.

In the current code, we are carrying around the "sign" variable in the 
cdc_ncm_fill_tx_frame: why? Can different NCM packets have different sign 
settings?
Thank you guys, waiting for your replies,
Enrico
