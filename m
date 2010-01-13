From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG? possible race due to the absence of barrier
Date: Wed, 13 Jan 2010 09:24:01 +0000
Message-ID: <20100113092401.GC6053@ff.dom.local>
References: <2014bcab1001122035x57717821tac399330fd29883c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: =?us-ascii?B?PT9JU08tODg1OS0yP1E/PTNGPTNGX3NoaW5faG9uZz89?=
	<hongshin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:4243 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094Ab0AMJYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 04:24:09 -0500
Received: by fg-out-1718.google.com with SMTP id 22so113921fge.1
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2010 01:24:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <2014bcab1001122035x57717821tac399330fd29883c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-01-2010 05:35, ?? shin hong wrote:
> Hi. I am reporting a type of suspected bugs due to
> the lack of enforcing operation order by memory barrier.
> 
> I found this issue while I read the code, so that
> it might not be real. But, please examine this issue.
> 
> We often allocate an object, initialize it, and then link it to a data
> structure.
> Then any thread can access the object.
> 
> For this pattern of programming, it seems to be necessary that
> memory barrier should confirm that the initializations and the linking
> to global data structures are not disordered by CPU or compilers.
> 
> atm_add_addr() in /net/atm/addr.c has the following code:
> 
>  88   this = kmalloc(sizeof(struct atm_dev_addr), GFP_ATOMIC);
>  89   if (!this) {
>  90     spin_unlock_irqrestore(&dev->lock, flags);
>  91     return -ENOMEM;
>  92   }
>  93   this->addr = *addr;
>  94   list_add(&this->entry, head);
> 
> The operation at line 93 might be executed earlier than that of line 94.
> Then, the other thread might read uninitialized value of this
> if there is other concurrent thread which iterates the list.
> 
> Please examine this issue and let me know your opinions.

Should be safe under the spin_lock() (and its barriers).

Regards,
Jarek P.
