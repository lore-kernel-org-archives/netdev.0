From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 4/6] myri10ge - First half of the driver
Date: Fri, 12 May 2006 01:53:44 +0200
Message-ID: <4463CE88.20301@myri.com>
References: <446259A0.8050504@myri.com> <Pine.GSO.4.44.0605101438410.498-100000@adel.myri.com> <20060510231347.GC25334@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750862AbWEKXyA@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060510231347.GC25334@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
>
>> +	spin_lock(&mgp->cmd_lock);
>> +	response->result = 0xffffffff;
>> +	mb();
>> +	myri10ge_pio_copy((void __iomem *) cmd_addr, buf, sizeof (*buf));
>> +
>> +	/* wait up to 2 seconds */
>>     
>
> You must not hold a spinlock for up to 2 seconds.
>   

We are working on reducing the delay to about 15ms. It only occurs when
the driver is loaded or the link brought up.

>> +	for (sleep_total = 0; sleep_total < (2 * 1000); sleep_total += 10) {
>> +		mb();
>> +		if (response->result != 0xffffffff) {
>> +			if (response->result == 0) {
>> +				data->data0 = ntohl(response->data);
>> +				spin_unlock(&mgp->cmd_lock);
>> +				return 0;
>> +			} else {
>> +				dev_err(&mgp->pdev->dev,
>> +					"command %d failed, result = %d\n",
>> +				       cmd, ntohl(response->result));
>> +				spin_unlock(&mgp->cmd_lock);
>> +				return -ENXIO;
>>     
>
> Return in a middle of a spinlock-intensive function. :o(
>   

What do you mean ?

>   
>> +{
>> +	struct sk_buff *skb;
>> +	unsigned long data, roundup;
>> +
>> +	skb = dev_alloc_skb(bytes + 4096 + MYRI10GE_MCP_ETHER_PAD);
>> +	if (skb == NULL)
>> +		return NULL;
>>     
>
> Imho you will want to work directly with pages shortly.
>   

We had thought about doing this, but were a little nervous since we did
not know of any other drivers that worked directly with pages.  If this
is an official direction to work directly with pages, we will. But the
existing approach is well tested through our beta cycle, and we would
prefer to leave it as is and update to a pages based approach in the
future.


Thanks a lot for all the comments.

Brice
