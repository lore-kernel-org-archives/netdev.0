From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 3/5] net:stmmac: ensure we reclaim all dirty
 descriptors.
Date: Mon, 21 Oct 2013 11:32:07 -0700
Message-ID: <1382380327.3284.77.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
	 <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com>
	 <5264EEE9.8070607@st.com> <526527DE.5060906@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>, netdev@vger.kernel.org
To: Jimmy PERCHET <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:46491 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425Ab3JUScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 14:32:08 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so8510962pad.33
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 11:32:08 -0700 (PDT)
In-Reply-To: <526527DE.5060906@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-21 at 15:10 +0200, Jimmy PERCHET wrote:
> Hello Peppe,
> 

> I can reproduce this problem by issuing 9KiB jumbo frames on 10MBit/s link.
> If socket's wmemory size is about 500kiB (or less), the transfer stall.
> (I guess it is reproducible with 1500o frames by decreasing
> socket's wmemory to 90KB)
> Re-arming the timer fix this behaviour.
> 
> Here my understanding of this issue : 
> With 9KiB frames and 500kiB of wmemory, only 60 frames can be
> prepared in a row. It is below the tx coalescence threshold,
> so there will be no interrupt. When the tx coalescence timer 
> expires (40ms after), only five descriptors have to be
> freed (9000*5 @ 10Mbit/s = 34ms), it is not enough to reach
> the socket's wake-up threshold. We get into a deadlock :
> *Socket is waiting for free buffers before performing new transfer.
> *Driver is waiting for new transfer before performing cleanup.
> 
> Maybe, it is not a real life use-case, and is not worth
> a patch. What do you think ?
> 

I think there is probably a bug in the driver, a race of some sort,
and it would be better to find it and fix it ;)
