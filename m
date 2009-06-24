From: Franco Fichtner <franco@marian.de>
Subject: Re: [net-2.6 PATCH 1/2] qla3xxx: Give the PHY time to come out of
 reset.
Date: Wed, 24 Jun 2009 10:56:11 +0200
Message-ID: <4A41EA2B.20306@marian.de>
References: <1245783602-6542-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:51218 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbZFXI4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 04:56:19 -0400
In-Reply-To: <1245783602-6542-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
> +	/* Give the PHY time to come out of reset. */
> +	mdelay(100);
>   

Why *delay* for 100ms? This is something I pointed out quite a while ago 
when
you first introduced your driver.

Looking at the other patch where you eventually replaced the delay with 
a sleep
left the door wide open for a lock related issue. So I can see why the 
delay works
"better" for you.

However, I also recall pointing out the locking in this driver needed 
some work,
because there were spinlocks held over the duration of numerous function 
calls.
It seemed like a mess, but nobody cared.


Franco
