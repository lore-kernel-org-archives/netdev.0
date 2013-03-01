From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: regression of netdev stats
Date: Fri, 1 Mar 2013 07:47:16 -0800
Message-ID: <1362152836.6212.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <878v67xnkr.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: nsujir@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: "OGAWA Hirofumi" <hirofumi@mail.parknet.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3996 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab3CAPr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 10:47:27 -0500
In-Reply-To: <878v67xnkr.fsf@devron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-01 at 22:21 +0900, OGAWA Hirofumi wrote: 
> Hi,
> 
> f4a46d1f46a8fece34edd2023e054072b02e110d (tg3: Prevent spurious tx
> timeout by setting carrier off before tx disable.) seems to add the bug.
> 
> On 3.8.1 (I didn't use 3.7.x series), "ifconfig" commands doesn't show
> any stats, i.e. all stats are zero.

No stats on an active device transmitting and receiving packets?  I
don't seem to see the same problem, but we'll look into this further.
Thanks.

> And bisect points the above commit.
> In fact, reverting the above patch fixes the regression of netdev stats.
> 
> This patch looks like strange, and I'm not sure what this want to do.
> Any ideas?

Every time we reset the device (ethtool, MTU change, etc), we need to
turn off all the tx queues before resetting.  As soon as we turn off
these queues, if we don't turn off carrier, a tx timeout may be
triggered if it's been more than 5 seconds since the last transmit on
any of the tx queues.  These tx timeouts cause unnecessary concern to
the user.

> 
> Well, anyway, this is bug report.
> 
> Thanks.
