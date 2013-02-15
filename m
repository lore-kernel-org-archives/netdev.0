From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Fri, 15 Feb 2013 04:42:27 +0100
Message-ID: <511DAEA3.4080201@250bpm.com>
References: <1360311077-14474-1-git-send-email-sustrik@250bpm.com> <20130214145430.04f8750c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Eric Wong <normalperson@yhbt.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20130214145430.04f8750c.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Thanks for the detailed code review! I'll have a look at all the 
problems you've pointed out, however, one quick question:

>> -	ret = seq_printf(m, "eventfd-count: %16llx\n",
>> -			 (unsigned long long)ctx->count);
>> +	if (ctx->flags&  EFD_MASK) {
>> +		ret = seq_printf(m, "eventfd-mask: %x\n",
>> +				 (unsigned)ctx->mask.events);
>> +	} else {
>> +		ret = seq_printf(m, "eventfd-count: %16llx\n",
>> +				 (unsigned long long)ctx->count);
>> +	}
>>   	spin_unlock_irq(&ctx->wqh.lock);
>
> This is a non-back-compatible userspace interface change.  A procfs
> file which previously displayed
>
> 	eventfd-count: nnnn
>
> can now also display
>
> 	eventfd-mask: nnnn
>
> So existing userspace could misbehave.
>
> Please fully describe the proposed interface change in the changelog.
> That description should include the full pathname of the procfs file
> and example before-and-after output and a discussion of whether and why
> the risk to existing userspace is acceptable.

I am not sure what the policy is here. Is not printing out the state of 
the object acceptable way to maintain backward compatibility? If not so, 
does new type of object require new procfs file, which, AFAIU, is the 
only way to retain full backward compatibility?

Martin
