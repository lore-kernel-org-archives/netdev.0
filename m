From: David Miller <davem@davemloft.net>
Subject: Re: tg3: unable to handle null pointer dereference
Date: Fri, 06 Apr 2007 17:36:00 -0700 (PDT)
Message-ID: <20070406.173600.38712619.davem@davemloft.net>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	<20070406214014.GF3346@us.ibm.com>
	<1175900233.7911.87.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nacc@us.ibm.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933638AbXDGAgE@vger.kernel.org>
In-Reply-To: <1175900233.7911.87.camel@dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 06 Apr 2007 15:57:13 -0700

> On Fri, 2007-04-06 at 14:40 -0700, Nishanth Aravamudan wrote:
> 
> > 2.6.21-rc5 is ok. 2.6.21-rc6 results in
> > 
> > [   14.241665] Unable to handle kernel NULL pointer dereference (address 0000000000000000)
> 
> Sorry, I think this should fix it:
> 
> [TG3]: Fix crash during tg3_init_one().
> 
> The driver will crash when the chip has been initialized by EFI before
> tg3_init_one().  In this case, the driver will call tg3_chip_reset()
> before allocating consistent memory.
> 
> The bug is fixed by checking for tp->hw_status before accessing it
> during tg3_chip_reset().
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
