From: Nick Krause <xerofoify@gmail.com>
Subject: Re: [PATCH] Missing return check against Null for return value of netdev_alloc_dev_skb()
Date: Sun, 15 Jun 2014 23:28:50 -0400
Message-ID: <CAPDOMVhV3eKJ78-d_F_TTFjM+GDEdqpMSMFEQ8jOEnrbBchHqw@mail.gmail.com>
References: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>
	<20140614.235300.1228145928404410306.davem@davemloft.net>
	<CAPDOMVgV8V8fPpZupwQaDERiK-0OMLt66LULR6Biw1=8LJhOKw@mail.gmail.com>
	<20140615.192635.533361731164638772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andriy.shevchenko@linux.intel.com, dvhart@linux.intel.com,
	jeffrey.t.kirsher@intel.com, ast@plumgrid.com, dborkman@redhat.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140615.192635.533361731164638772.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fair enjoy I was wondering if it fails I can run a goto statement and
then free the memory for the tx as needed.
Cheers Nick
P.S. That was really stupid I didn't think that through at all :)

On Sun, Jun 15, 2014 at 10:26 PM, David Miller <davem@davemloft.net> wrote:
> From: Nick Krause <xerofoify@gmail.com>
> Date: Sun, 15 Jun 2014 16:27:23 -0400
>
>> From 62b0d77a1430f74b7f5c008c5e8bec11604b33b0 Mon Sep 17 00:00:00 2001
>> From: Nick <xerofoify@gmail.com>
>> Date: Sun, 15 Jun 2014 16:16:14 -0400
>> Subject: [PATCHv2] Fixes return logic of function of pch_gbe_alloc_tx_buffers()
>> Here is the fixed patch changed return type of function to int in
>> order to use return -ENOMEM as with the function above it , seems to
>> fit , otherwise returns 0.
>>  Report if it breaks anything related to this driver.
>> Signed-off-by: Nick <xerofoify@gmail.com>
>
> Nobody is checking the return value, you can't just change the function to
> return an error code, you have to make the caller act upon it appropriately
> as well.
>
> I'm very much not confident that you are willing to put in the effort
> necessary to fix this problem properly.
>
> I told you explicitly that if this memory allocation failure occurs, the
> bringup of the device has to fail.
>
> Your patch is making the situation worse, it breaks when there is an
> allocation failure, leaving the TX run partially allocated so that the
> driver will crash with an OOPS later.
>
> From your first iteration, you aren't build testing this change, and I
> therefore severely doubt you are functionally testing this change either.
>
> I hate to be harsh, but this is an extremely _poor_ patch submission.
