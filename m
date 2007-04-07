From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: tg3: unable to handle null pointer dereference
Date: Fri, 6 Apr 2007 18:53:01 -0700
Message-ID: <20070407015301.GA9537@us.ibm.com>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org> <20070406214014.GF3346@us.ibm.com> <1175900233.7911.87.camel@dell> <20070406.173600.38712619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964932AbXDGBz4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070406.173600.38712619.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06.04.2007 [17:36:00 -0700], David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 06 Apr 2007 15:57:13 -0700
> 
> > On Fri, 2007-04-06 at 14:40 -0700, Nishanth Aravamudan wrote:
> > 
> > > 2.6.21-rc5 is ok. 2.6.21-rc6 results in
> > > 
> > > [   14.241665] Unable to handle kernel NULL pointer dereference (address 0000000000000000)
> > 
> > Sorry, I think this should fix it:
> > 
> > [TG3]: Fix crash during tg3_init_one().
> > 
> > The driver will crash when the chip has been initialized by EFI before
> > tg3_init_one().  In this case, the driver will call tg3_chip_reset()
> > before allocating consistent memory.
> > 
> > The bug is fixed by checking for tp->hw_status before accessing it
> > during tg3_chip_reset().
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Applied, thanks Michael.

FWIW, tested, no panic.

Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
