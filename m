From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH net-next 05/22] cxgb4: Add T5 write combining support
Date: Tue, 12 Mar 2013 09:42:05 -0500
Message-ID: <513F3EBD.5020504@opengridcomputing.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com> <1363088794-31453-6-git-send-email-vipul@chelsio.com> <20130312.081927.1036246728528667686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, naresh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, arvindb-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130312.081927.1036246728528667686.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/12/2013 7:19 AM, David Miller wrote:
> From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> Date: Tue, 12 Mar 2013 17:16:17 +0530
>
>> +				writel(n,  adap->bar2 + q->udb + 8);
>> +#if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
>> +			asm volatile("sfence" : : : "memory");
>> +#endif
> There is absolutely no way I'm letting anyone put crap like this
> into a driver.
>
> Use a portable inteface, and if one does not exist create one.

I guess you'll have to add a wc_wmb() function for all the hw platforms 
supported by the kernel.  I see libibverbs defines this for the user 
side in include/infiniband/arch.h, and that could be used as the meat of 
the hw platform-specific implementations.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
