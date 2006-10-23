From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: [PATCH] sky2: 88E803X transmit lockup
Date: Mon, 23 Oct 2006 20:20:26 +0100
Message-ID: <6278d2220610231220r7cfd95b4ueac267e511162e0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:63204 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S965055AbWJWTU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 15:20:28 -0400
Received: by ug-out-1314.google.com with SMTP id q2so1481119uge
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2006 12:20:27 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The reason sky2 driver was locking up on transmit on the Yukon-FE chipset
> is that it was misconfiguring the internal RAM buffer so the transmitter
> and receiver were sharing the same space.
>
> The code assumed there was 16K of RAM on Yukon-FE (taken from vendor driver
> sk98lin which is even more f*cked up on this). Then it assigned based on that.
> The giveaway was that the registers would only hold 9bits so both RX/TX
> had 0..1ff for space. It is a wonder it worked at all!
>
> This patch addresses this, and fixes an easily reproducible hang on Transmit.
> Only the Yukon-FE chip is Marvell 88E803X (10/100 only) are affected.
[snip]

This patch works great - without it, I get only a few minutes of use
from my home dir over NFS4 before the NIC stops transmitting. This is
on a recent Yonah Sony VGN-SZ notebook w/ 88E8036 Marvel Sk-Y2.

Thanks again Stephen!
-- 
Daniel J Blueman
