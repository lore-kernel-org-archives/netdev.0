From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Tue, 14 Apr 2015 00:53:43 +0200
Message-ID: <552C48F7.5030901@gmx.de>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>	 <1427982999.18722.35.camel@xylophone.i.decadent.org.uk>	 <552C2849.2080503@cogentembedded.com> <552C3F9C.5070200@gmx.de> <1428964268.8341.46.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1428964268.8341.46.camel@xylophone.i.decadent.org.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.04.2015 00:31, Ben Hutchings wrote:

>> >> This driver looks somewhat similar to sh-eth, but lacks some of the
>> >> recent bug fixes made to that.  At least commit 283e38db65e7 ("sh_eth:
>> >> Fix serialisation of interrupt disable with interrupt & NAPI handler")
>> >> appears to be applicable, but there are probably others.
>> > 
>> >     I suspect this issue applies to many drivers...
>> >     I couldn't reproduce the bug that patch was fixing, so left this fix out 
>> > for the time being. Others cases were fixed (if applicable).
>> 
>> Maybe its just harder to trigger but it indeed looks similar to what Ben
>> has fixed for sh-eth. I wonder if that shutdown flag in the fix is
>> really needed though. IMHO it should be save if we simply call
>> napi_disable first, then disable irqs on hardware and finally
>> synchronize_irq...
> 
> In sh_eth: if we call napi_disable() first, EESR_RX_CHECK can still be
> set and nothing will clear it.  If only one CPU is online this can hard
> hang the system.  Please trust that I did consider and rule out the
> simpler approaches first.
> 

The idea was to check the return value from napi_schedule_prep() and in
case it returns "false" use this as an indication for a shutdown. In
case of sh_eth this would be sh_eth_write(ndev, 0, EESIPR) for example.

Lino


