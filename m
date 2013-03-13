From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next 05/22] cxgb4: Add T5 write combining support
Date: Wed, 13 Mar 2013 20:06:04 +0530
Message-ID: <51408ED4.40400@chelsio.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com> <1363088794-31453-6-git-send-email-vipul@chelsio.com> <20130312.081927.1036246728528667686.davem@davemloft.net> <513F3EBD.5020504@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	"JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Dimitrios Michailidis <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Naresh Kumar Inna <naresh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Arvind Bhushan <arvindb-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Abhishek Agrawal <abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <513F3EBD.5020504-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 12-03-2013 20:12, Steve Wise wrote:
> On 3/12/2013 7:19 AM, David Miller wrote:
>> From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>> Date: Tue, 12 Mar 2013 17:16:17 +0530
>>
>>> +				writel(n,  adap->bar2 + q->udb + 8);
>>> +#if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
>>> +			asm volatile("sfence" : : : "memory");
>>> +#endif
>> There is absolutely no way I'm letting anyone put crap like this
>> into a driver.
>>
>> Use a portable inteface, and if one does not exist create one.
> 
> I guess you'll have to add a wc_wmb() function for all the hw platforms 
> supported by the kernel.  I see libibverbs defines this for the user 
> side in include/infiniband/arch.h, and that could be used as the meat of 
> the hw platform-specific implementations.
> 
I see that normal wmb() code for x86_64 architecture is same as what
above #ifdef condition is doing. To be more clear I looked at the
assembly code for wmb and find that it is converted into 'sfence'
instruction. So, I think above code should be replaced with wmb call
which will also take care of portability on different architecture. I
will submit the series again soon.

I would like to request RDMA/cxgb4 and csiostor driver maintainer to
review the series if it has not been done already. It would be great If
I can include review comments from them in my next version of series.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
