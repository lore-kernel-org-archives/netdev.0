From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]  net/gt96100eth: replace gt96100_delay() with msleep_interruptible()
Date: Fri, 05 Nov 2004 02:47:02 -0500
Message-ID: <418B2FF6.8030907@pobox.com>
References: <E1CO1vu-0002Lf-5c@sputnik> <4184C72F.8000905@pobox.com> <20041101190841.GB1730@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20041101190841.GB1730@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nishanth Aravamudan wrote:
> On Sun, Oct 31, 2004 at 06:06:23AM -0500, Jeff Garzik wrote:
> 
>>janitor@sternwelten.at wrote:
>>
>>>@@ -528,7 +517,7 @@ abort(struct net_device *dev, u32 abort_
>>>	// wait for abort to complete
>>>	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
>>>		// snooze for 20 msec and check again
>>>-		gt96100_delay(1);
>>>+		msleep_interruptible(20);
>>>	
>>>		if (--timedout == 0) {
>>
>>
>>don't change the behavior of the driver, even if it disagrees with the 
>>comment.
> 
> 
> Ok, please find the corrected patch below.
> 
> Description: Uses msleep_interruptible() instead of gt96100_delay()
> to guarantee the task delays as expected. Removes prototype and
> definition of now unused gt96100_delay() function. Corrects one comment
> to correspond to the code.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> 
> --- 2.6.10-rc1-vanilla/drivers/net/gt96100eth.c	2004-10-30 15:33:30.000000000 -0700
> +++ 2.6.10-rc1/drivers/net/gt96100eth.c	2004-11-01 11:05:37.000000000 -0800
> @@ -59,7 +59,6 @@
>  // prototypes
>  static void* dmaalloc(size_t size, dma_addr_t *dma_handle);
>  static void dmafree(size_t size, void *vaddr);
> -static void gt96100_delay(int msec);
>  static int gt96100_add_hash_entry(struct net_device *dev,
>  				  unsigned char* addr);
>  static void read_mib_counters(struct gt96100_private *gp);
> @@ -183,16 +182,6 @@ static void dmafree(size_t size, void *v
>  	free_pages((unsigned long)vaddr, get_order(size));
>  }
>  
> -static void gt96100_delay(int ms)
> -{
> -	if (in_interrupt())
> -		return;
> -	else {
> -		current->state = TASK_INTERRUPTIBLE;
> -		schedule_timeout(ms*HZ/1000);

I'm still worried about this patch, because

1) in_interrupt() check disappears, and

2) does driver already include linux/delay.h ?
