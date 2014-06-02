From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: use RNC mode for R8A7790/R87791
Date: Mon, 02 Jun 2014 23:33:47 +0400
Message-ID: <538CD19B.5060208@cogentembedded.com>
References: <1401729456-23514-1-git-send-email-ben.dooks@codethink.co.uk> <20140602.115303.1283021229124256917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@codethink.co.uk, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damn@opensource.se,
	horms@verge.net.au, yoshihiro.shimoda.uh@renesas.com,
	cm-hiep@jinso.co.jp
To: David Miller <davem@davemloft.net>, ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:57678 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbaFBTdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 15:33:47 -0400
Received: by mail-lb0-f174.google.com with SMTP id n15so2791163lbi.5
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 12:33:45 -0700 (PDT)
In-Reply-To: <20140602.115303.1283021229124256917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/02/2014 10:53 PM, David Miller wrote:

>> The current behaviour of the sh_eth driver is not to use the RNC bit
>> for the receive ring. This means that every packet recieved is not only
>> generating an IRQ but it also stops the receive ring DMA as well until
>> the driver re-enables it after unloading the packet.

>> This means that a number of the following errors are generated due to
>> the receive packet FIFO overflowing due to nowhere to put packets:

>> 	net eth0: Receive FIFO Overflow

>> I have tested the RMCR_RNC configuration with NFS root filesystem and
>> the driver has not failed yet.  There are further test reports from
>> Sergei Shtylov and others for both the R8A7790 and R8A7791.

>> There is also feedback fron Cao Minh Hiep[1] which reports the
>> same issue in (http://comments.gmane.org/gmane.linux.network/316285)
>> showing this fixes issues with losing UDP datagrams under iperf.

>> Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

> Given the description, I can't fathom a reason why this wouldn't be
> set always, for every chip.

> Do some chips not implement this bit at all?

    Looks like the early SH2/3 SoCs didn't implement the whole register.
Despite that, sh_eth_dev_init() always writes to this register... :-/
So far, the RMCR.RNC bit was mostly set for the Gigabit-capable controllers, 
however that rule wasn't strictly followed. Well, this driver is still a mess, 
and it's hard to deal with it without the necessary documentation.

WBR, Sergei
