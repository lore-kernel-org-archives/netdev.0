From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v2] sh_eth: use RNC mode for R8A7790/R87791
Date: Mon, 02 Jun 2014 20:06:52 +0100
Message-ID: <538CCB4C.1080901@codethink.co.uk>
References: <1401729456-23514-1-git-send-email-ben.dooks@codethink.co.uk> <20140602.115303.1283021229124256917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@codethink.co.uk, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damn@opensource.se,
	horms@verge.net.au, yoshihiro.shimoda.uh@renesas.com,
	cm-hiep@jinso.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:51277 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751338AbaFBTHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 15:07:01 -0400
In-Reply-To: <20140602.115303.1283021229124256917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/14 19:53, David Miller wrote:
> From: Ben Dooks <ben.dooks@codethink.co.uk>
> Date: Mon,  2 Jun 2014 18:17:36 +0100
> 
>> The current behaviour of the sh_eth driver is not to use the RNC bit
>> for the receive ring. This means that every packet recieved is not only
>> generating an IRQ but it also stops the receive ring DMA as well until
>> the driver re-enables it after unloading the packet.
>>
>> This means that a number of the following errors are generated due to
>> the receive packet FIFO overflowing due to nowhere to put packets:
>>
>> 	net eth0: Receive FIFO Overflow
>>
>> I have tested the RMCR_RNC configuration with NFS root filesystem and
>> the driver has not failed yet.  There are further test reports from
>> Sergei Shtylov and others for both the R8A7790 and R8A7791.
>>
>> There is also feedback fron Cao Minh Hiep[1] which reports the
>> same issue in (http://comments.gmane.org/gmane.linux.network/316285)
>> showing this fixes issues with losing UDP datagrams under iperf.
>>
>> Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> 
> Given the description, I can't fathom a reason why this wouldn't be
> set always, for every chip.
> 
> Do some chips not implement this bit at all?

I do not have access to enough of the sh-eth capable data-sheets
to know why this is.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
