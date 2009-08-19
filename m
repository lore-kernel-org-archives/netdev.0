From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 19 Aug 2009 23:07:21 +0200
Message-ID: <200908192307.22112.rene.mayrhofer@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <200908190902.02854.rene.mayrhofer@gibraltar.at> <392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:50323 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbZHSVH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 17:07:29 -0400
In-Reply-To: <392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mike,

Am Mittwoch, 19. August 2009 17:00:31 schrieb Mike McCormack:
> * try the latest sky2 code from net-next-2.6
> * try adding an msleep(1) after sky2_rx_stop() in sky2_down()
> * try adding a check for rx_ring and tx_ring being NULL in
> sky2_status_intr(), and disable napi while freeing the buffers in
> sky2_down()
>
> I've got an untested, ad-hoc patch against net-next-2.6 for the last
> two bits ...

Pulling the latest sky2.c and sky2.h from net-next-2.6 and applying the patch 
rids me of the oops - it is unreproducible right now. However, a networking 
restart (i.e. all interfaces attached to sky2) leaves the devices in a state 
where they no longer receive any network packets (at least nothing visible in 
tcpdump). In this state, rmmod sky2 / modprobe sky2 gives:

[  718.502717] sky2 0000:01:00.0: unsupported chip type 0xff                    
[  718.510517] sky2: probe of 0000:01:00.0 failed with error -95                
[  718.517900] sky2 0000:02:00.0: unsupported chip type 0xff                    
[  718.524408] sky2: probe of 0000:02:00.0 failed with error -95                
[  718.531617] sky2 0000:03:00.0: unsupported chip type 0xff                    
[  718.538104] sky2: probe of 0000:03:00.0 failed with error -95                
[  718.545344] sky2 0000:04:00.0: unsupported chip type 0xff                    
[  718.551818] sky2: probe of 0000:04:00.0 failed with error -95 

I will now try the net-next-2.6 version without your patch again but was under 
the impression that it still oopsed when I tried it initially. Better to 
double-check before I give erroneous debugging results, though...

best regards,
Rene

-- 
-------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/
