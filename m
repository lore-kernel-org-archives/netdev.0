From: Angelo Dureghello <angelo70@gmail.com>
Subject: Re: Micrel KSZ8031 - phy link missing
Date: Fri, 10 Oct 2014 14:54:18 +0200
Message-ID: <5437D6FA.9070304@gmail.com>
References: <915054555B5659448ACF8A70E114824D0163C79016@Exchange2010.kamstrup.dk> <5437A7A2.3020700@gmail.com> <915054555B5659448ACF8A70E114824D0163C7A77B@Exchange2010.kamstrup.dk> <5437BACA.1000201@gmail.com> <915054555B5659448ACF8A70E114824D0163C7A7F9@Exchange2010.kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Bruno Thomsen <bth@kamstrup.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47492 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbaJJMyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 08:54:22 -0400
Received: by mail-wi0-f174.google.com with SMTP id cc10so1962556wib.1
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 05:54:21 -0700 (PDT)
In-Reply-To: <915054555B5659448ACF8A70E114824D0163C7A7F9@Exchange2010.kamstrup.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Bruno,

i added the fixup, nothing changes.
I am tracing flags at ksz8021_config_ini:

Starting network...
davinci_mdio davinci_mdio.0: resetting idled controller
micrel.c: ksz8021_config_init: flags: 0x00000203
net eth0: attached PHY driver [Micrel KSZ8031] 
(mii_bus:phy_addr=davinci_mdio-0:00, id=221556)
udhcpc (v1.20.2) started
Sending discover...
Sending discover...
Sending discover...
No lease, failing

So, MICREL_PHY_50MHZ_CLK seems to be set.
I have the suspect that the clock is not received from the phy. 
Unfortunately i can't check
with the scope, the micrel chip is on a hidden part of the board.

 From what i remember, when i was trying to init emac/phy by devicetree, 
it was working.

[root@barix ~]# cat /sys/class/net/eth0/carrier
0
[root@barix ~]# cat /sys/class/net/eth0/carrier_changes
1
[root@barix ~]#

I realize at this point is my own debugging / issue.
But if you have any idea how to debug this, i can put some traces here 
and there.

Still many thanks,
Angelo



On 10/10/2014 13:32, Bruno Thomsen wrote:
> Hey again,
> Looks like you just enable clock output from DA850. You also need to setup PHY to accept RMII clock from MAC.
> This can be done with something like this...
>
> ...
>   
>
