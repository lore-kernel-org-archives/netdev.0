From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Fri, 9 Sep 2005 13:08:24 -0500
Message-ID: <3D0A0EB3-0C82-4C58-8FE1-11DC9803E4A7@freescale.com>
References: <200509080125.j881PcL9015847@hera.kernel.org>  <431F9899.4060602@pobox.com> <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>  <1126184700.4805.32.camel@tsc-6.cph.tpack.net>  <Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de> <1126190554.4805.68.camel@tsc-6.cph.tpack.net> <Pine.LNX.4.63.0509081713500.22954@dingo.iwr.uni-heidelberg.de> <62AA8EFA-7D65-4E87-B71F-55A07321011E@freescale.com> <Pine.LNX.4.63.0509091152450.23760@dingo.iwr.uni-heidelberg.de>
Mime-Version: 1.0 (Apple Message framework v734)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030308AbVIISIg@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.63.0509091152450.23760@dingo.iwr.uni-heidelberg.de>
To: Bogdan Costescu <Bogdan.Costescu@iwr.uni-heidelberg.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 9, 2005, at 05:10, Bogdan Costescu wrote:

> On Thu, 8 Sep 2005, Andy Fleming wrote:
>
>
>> Is the cost of an extra read every minute really too high?
>>
>
> You probably didn't look at the code. The MII registers are not  
> exposed in the PCI space, they need to be accessed through a serial  
> protocol, such that each MII register read is in fact about 200 (in  
> total) of outw and inw/inl operations.

I certainly looked at the code.  I'm aware that there are probably  
about 150 microseconds of work, tops, to do each read.  Do it outside  
of interrupt time, and separate from the normal thread of the driver  
(like a task struct), and it shouldn't take up that much CPU time.   
And if it's being done every minute, it's really not a big deal, is it?

Anyway, it's not a big deal to me.  I agree that doing only one read,  
if the link is reported as up, is a good idea.  I'll be sure to put  
it in the next rev of the PHY Layer.

I also agree that polling should be done every 5 seconds, at least  
when the link is down.

Andy Fleming
Freescale Open Source Team
