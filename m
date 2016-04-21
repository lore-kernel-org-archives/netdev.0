From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCH V2] net: stmmac: socfpga: Remove re-registration of reset
 controller
Date: Thu, 21 Apr 2016 09:52:00 -0500
Message-ID: <5718E910.10409@opensource.altera.com>
References: <1461110753-7641-1-git-send-email-marex@denx.de>
 <5717F1DF.1020004@opensource.altera.com> <5718023F.1060707@denx.de>
 <57183E7B.5050804@opensource.altera.com> <5718BEDB.4010303@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: Marek Vasut <marex@denx.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0086.outbound.protection.outlook.com ([157.56.110.86]:20848
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752046AbcDUOwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 10:52:15 -0400
In-Reply-To: <5718BEDB.4010303@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/21/2016 06:51 AM, Marek Vasut wrote:
>>>>
>>>> if you modify the patch to call stmmac_dvr_probe() before calling
>>>> socfpga_dwmac_init(), then you would already have the reset control
>>>> information.
>>>
>>> I was under the impression that you must call socfpga_dwmac_init()
>>> before stmmac_dvr_probe() for whatever hardware-related reason. If
>>> you are absolutely certain this is not necessary, then that's just
>>> perfect and the patch can be simplified even further -- just remove
>>> the call to socfpga_dwmac_init() from probe altogether , the dwmac
>>> core code will call plat_dat->init at the end of probe .
>>>
>>> So shall we do that ? I am happy to spin V3 like that if you confirm
>>> that it's legal to do things in the aforementioned order.
>>>
>>
>> AFAICT, I don't see any reason why the socfpga_dwmac_init() has to go
>> before the stmmac_dvr_probe(). I tested this by using U-Boot to put the
>> PHY modes in the system manager into a different mode, and put the
>> ethernet IP into reset. Linux was able to use ethernet just fine with
>> the aformentioned order.
> 
> Ha, the dwmac code does not call the ->init, so you have to call it from
> the socfpga-dwmac probe afterall. I will send a V3 now and do
> it just like you suggested. I will send a RFC for calling ->init and
> ->exit from the stmmac common code too.
> 

Yes, I saw this too. Was going to wait until after this patch to
follow-up. Looks like you already did! Thanks!

Dinh
