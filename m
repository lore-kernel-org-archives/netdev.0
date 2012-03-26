From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] netdev: fix compile issues for !CONFIG_PCI in 3c59x
Date: Mon, 26 Mar 2012 11:38:32 -0400
Message-ID: <4F708D78.2040102@windriver.com>
References: <1332724306-8799-1-git-send-email-paul.gortmaker@windriver.com> <CAP=VYLpOJOueFfzxFGCu5cKQ9--F8CqC5JWjBxej7u=8z3K0xQ@mail.gmail.com> <4F70834E.3000308@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@gmail.com>,
	<klassert@mathematik.tu-chemnitz.de>, <netdev@vger.kernel.org>,
	<linux-mips@linux-mips.org>
To: Sergei Shtylyov <sshtylyov@mvista.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49865 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932614Ab2CZPi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 11:38:58 -0400
In-Reply-To: <4F70834E.3000308@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-03-26 10:55 AM, Sergei Shtylyov wrote:
> Hello.
> 
> On 03/26/2012 05:38 PM, Paul Gortmaker wrote:
> 
>>> I hate to add in more #ifdef CONFIG_PCI but there are already
>>> quite a few in this driver, and it seems like it hasn't been
>>> built with CONFIG_PCI set to off in quite some time.
> 
>> Actually, please scrap this patch.  The uglyness of more ifdefs
>> made me look at it again.  It should be do-able in a cleaner way
>> with stubs, and it appears this may even be similar to an old fail
>> from the past:
> 
>> http://lkml.indiana.edu/hypermail/linux/kernel/1107.3/00109.html
> 
>     Also, see this patch:
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=0da0ead90122578ef6e4afba9ba4bcd3455fd8e8
> 
>     The driver patch this was done for is still in the -mm tree after all these 
> years.:-)
> 
>> I'll dig into it some more and follow up.
> 
>     I thought I addressed all issues with compilation of this driver with 
> CONFIG_PCI=n. Apparently not, and some seem to have accumulated over time...

I got sidetracked working on other things, but I did manage to
learn this so far - It turns out that Randy fixed it and then
James un-fixed it in this commit:

commit 97a29d59fc222b36bac3ee3a8ae994f65bf7ffdf
Author: James Bottomley <James.Bottomley@HansenPartnership.com>
Date:   Mon Jan 30 10:40:47 2012 -0600

    [PARISC] fix compile break caused by iomap: make IOPORT/PCI mapping functions conditional

Reverting the above and mips builds 3c59x just fine.  Note that MIPS
allmodconfig does not have either CONFIG_GENERIC_IOMAP or the other
CONFIG_GENERIC_PCI_IOMAP options.

Paul.
--

> 
>> Thanks,
>> Paul.
> 
> WBR, Sergei
