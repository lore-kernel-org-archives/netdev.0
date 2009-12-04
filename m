From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [PATCH 2.6.32 3/3] net: Make ks8851 snl work under Beagle Zippy combo board
Date: Thu, 3 Dec 2009 17:17:09 -0800
Message-ID: <14385191E87B904DBD836449AA30269D4F2135@MORGANITE.micrel.com>
References: <14385191E87B904DBD836449AA30269D021A42@MORGANITE.micrel.com> <20091203.160511.211490797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ben@simtec.co.uk>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755519AbZLDBU0@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091203.160511.211490797.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
> Date: Thu, 3 Dec 2009 13:30:03 -0800
> 
>> From: Tristram Ha <Tristram.Ha@micrel.com>
>> 
>> The Micrel KSZ8851 SNL Ethernet chip is used in the OMAP Beagle Zippy
combo board.  Requesting
>> interrupt using level triggering flag hangs the system because the
interrupt handling routine
>> is called continually.  Using edge triggering avoids this problem.
As a result, disabling
>> interrupt may not be necessary.   
>> 
>> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
> 
> You say "may not be necessary", do you actually know for sure?
> 
> This seems questionable, if the interrupt disabling was there for a
reason what has changed to
> make it such that it is no longer necessary? 

I have tested the KSZ8851 SNL driver using the OMAP Beagle Zippy combo
board, developed by Tin Can Tools.  Ben Dooks, who implemented the
original driver, has his own KSZ8851 SNL evaluation board, but he
probably did not run any performance test on the driver.  I did sent him
the changes before so that he can verify on his board, but I have not
received any response.

So I really do not know if interrupt disabling is necessary or not.  But
from my understanding of the SPI network driver model, it is almost
required the interrupt be edge triggered, as the hardware interrupt
cannot be disabled inside the actual interrupt handling routine.  So if
the interrupt is level triggered, the interrupt routine will be called
continually, and there is no chance for the workqueue to disable the
interrupt.  As the interrupt is edge triggered, I do not think the
interrupt needs to be disabled.
