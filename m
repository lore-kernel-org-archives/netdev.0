From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH v2] sh_eth: use RNC mode for R8A7790/R87791
Date: Tue, 3 Jun 2014 11:45:03 +0900
Message-ID: <538D36AF.6050303@renesas.com>
References: <1401729456-23514-1-git-send-email-ben.dooks@codethink.co.uk>	<20140602.115303.1283021229124256917.davem@davemloft.net>	<538CD19B.5060208@cogentembedded.com> <20140602.134915.1162774321657125992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"ben.dooks@codethink.co.uk" <ben.dooks@codethink.co.uk>,
	"linux-kernel@codethink.co.uk" <linux-kernel@codethink.co.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	"magnus.damn@opensource.se" <magnus.damn@opensource.se>,
	"horms@verge.net.au" <horms@verge.net.au>,
	"cm-hiep@jinso.co.jp" <cm-hiep@jinso.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:64449 "EHLO
	relmlie2.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752610AbaFCCpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 22:45:13 -0400
In-Reply-To: <20140602.134915.1162774321657125992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

(2014/06/03 5:49), David Miller wrote:
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Mon, 02 Jun 2014 23:33:47 +0400
> 
>>    Looks like the early SH2/3 SoCs didn't implement the whole register.
>> Despite that, sh_eth_dev_init() always writes to this register... :-/
>> So far, the RMCR.RNC bit was mostly set for the Gigabit-capable
>> controllers, however that rule wasn't strictly followed. Well, this
>> driver is still a mess, and it's hard to deal with it without the
>> necessary documentation.
> 
> Why don't we therefore:
> 
> 1) Skip the register write if the per-chip value is zero.
> 
> 2) Add the RNC bit to all of the gigabit capable controllers.
> 

Thank you for the suggestion.

I checked all of datasheets about the following LSIs.
 - sh7619, sh7710, sh7724, sh7734, sh7757(ether, gther),
   sh7763, r7s72100, r8a7740, r8a7778, r8a7790, r8a7791
   (There are in the "static struct platform_device_id sh_eth_id_table[]".)

And then, I found all of these LSIs have the "RNC" bit in the register.
Accurately some LSIs have a difference bit name like "RNR" or "RR". (I don't know why...)
However, the behavior of the bit is the same as all of these LSIs.

So, I think we are able to:
 - add the RNC bit to all of the ethernet controllers.
 - remove ".rmcr_value" in the "struct sh_eth_cpu_data".

Best regargds,
Yoshihiro Shimoda
