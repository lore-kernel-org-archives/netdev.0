From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] Netpoll support for Sibyte MAC
Date: Tue, 20 Mar 2007 21:35:53 +0300
Message-ID: <46002989.5000609@ru.mvista.com>
References: <20070319224311.GA10176@plexity.net> <20070320.102248.68134682.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dsaxena@plexity.net, netdev@vger.kernel.org, ralf@linux-mips.org,
	jeff@garzik.org, linux-mips@linux-mips.org, mlachwani@mvista.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:60007 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752810AbXCTSf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 14:35:26 -0400
In-Reply-To: <20070320.102248.68134682.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Atsushi Nemoto wrote:

>>NETPOLL support for Sibyte MAC

>>Signed-off-by: Manish Lachwani <mlachwani@mvista.com>
>>Signed-off-by: Deepak Saxena <dsaxena@mvista.com>

> If you added NETPOLL support, do not forget to ensure hard_start_xmit
> routine callable from interrupt context (or irq disabled).
> See commit bce305f4fe779f29d99d414685243f5da0803254 for example.

    You're absolutely right: this driver is very likely to blow up the caller 
when called with interrupts disabled -- it uses spin_unlock_irq() there! This 
*must* be fixed.

> ---
> Atsushi Nemoto

WBR, Sergei
