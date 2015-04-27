From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] ppp: mppe: fixes MPPE desync on links which don't
 guarantee packet ordering
Date: Sun, 26 Apr 2015 23:26:16 -0400 (EDT)
Message-ID: <20150426.232616.353503560380309931.davem@davemloft.net>
References: <1430073653-22131-1-git-send-email-sylvain.rochet@finsecur.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sylvain.rochet@finsecur.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1430073653-22131-1-git-send-email-sylvain.rochet@finsecur.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sylvain Rochet <sylvain.rochet@finsecur.com>
Date: Sun, 26 Apr 2015 20:40:51 +0200

> I am currently having an issue with PPP over L2TP (UDP) and MPPE in
> stateless mode (default mode), UDP does not guarantee packet ordering so
> we might get out of order packet. MPPE needs to be continuously synched
> so we should drop late UDP packet.
> 
> I added a printk on the number of time we rekeyed in MPPE decompressor,
> this is what we currently have if we receive a slightly out of order UDP
> packet:
 ...
> This is obviously wrong, we missed packet 1561 and we already rekeyed 2
> times for 1562 we previously received, we can't recover the decryption
> key we need for 1561, we should drop it instead of rekeying 4095 times.
> 
> This patch series drop any packet with are not within the 4096/2 forward
> window.

Series applied, thanks Sylvain.
