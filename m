From: Li Yang-R58472 <r58472@freescale.com>
Subject: RE: [RFC] Multi queue support in ethernet/freescale/ucc_geth.c
Date: Thu, 9 Feb 2012 10:44:54 +0000
Message-ID: <94F013E7935FF44C83EBE7784D62AD3F0571F5FE@039-SN2MPN1-022.039d.mgd.msft.net>
References: <4F2B1138.2090004@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4F2B1138.2090004@windriver.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Paul Gortmaker [mailto:paul.gortmaker@windriver.com]
> Sent: Friday, February 03, 2012 6:42 AM
> To: Li Yang-R58472
> Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org
> Subject: [RFC] Multi queue support in ethernet/freescale/ucc_geth.c
> 
> Hi Li,

Hi Paul,

Sorry for the late response due to holidays.

> 
> A while back DaveM mentioned that it would be good to break out the ring
> allocations[1] in this driver.
> 
> I was looking at it, and in the process noticed this:
> 
> $ grep 'numQueues.*=' drivers/net/ethernet/freescale/ucc_geth.c
>         .numQueuesTx = 1,
>         .numQueuesRx = 1,
> $
> 
> My interpretation of the above is that there is no way (aside from a code
> edit) to enable multi queue support.
> They are only ever assigned one time, to a value of one.
> 
> Assuming I'm not missing something obvious, is the multi queue support
> functional and tested, or just old code that never got tested and
> subsequently enabled?

Previously the device is only used on single core cpu, so we didn't have the incentive to enable multi-queue.  It is not tested on Linux currently.

> 
> The reason I ask, is that the ring allocation code gets rid of the loop
> wrapping it, if the driver is really only meant to ever have just single
> queues for Rx/Tx. And other areas of the driver can also be simplified
> accordingly as well.

Well.  I would prefer the other way which is to add the multi-queue support as we are using the QE in multi-core SoC and the current driver is having almost all the code needed for multi-queue except interface to the protocol layer.

- Leo
