From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: drivers/net/niu.c: memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len)?
Date: Fri, 21 Mar 2008 00:01:11 +0100
Message-ID: <47E2ECB7.5030304@tiscali.nl>
References: <47E2D08E.5050708@tiscali.nl> <20080320.142510.148381731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.tiscali.nl ([195.241.79.176]:34670 "EHLO
	smtp-out1.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072AbYCTXBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 19:01:14 -0400
In-Reply-To: <20080320.142510.148381731.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Roel Kluin <12o3l@tiscali.nl>
> Date: Thu, 20 Mar 2008 22:01:02 +0100
> 
>> in drivers/net/niu.c, line 6406, 6286 and 7173:
>>
>> memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);
>>
>> I noticed that "
>>
>> memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len)
>>
>> occurs much more often (15x). could it be that the first two arguments
>> are swapped in niu.c?
> 
> No, these calls are correct.  We are probing the device's permanent
> ethernet address, we first place it into dev->dev_addr and then we
> copy it into dev->perm_addr.
> 
> Please try to actually understand the pieces of strcpy and memcpy code
> you are "finding bugs" in before posting to the list as these analysis
> on false positives are going to eat up a lot of developer time.

Sorry for the noise (also for sound/sparc/dbri.c) and thanks for your
answers, It takes a lot more time for me to understand the code than it
will do for someone with more knowledge and experience with this driver, 

If drivers/net/niu.c copies in opposite direction compared to 80% of the
other memcpy calls - using these same variable names - and it is not
directly transparent why, My opinion is that either the naming is bad or
there is a lack of comment.

> I notice you posting several of these kinds of things.

Only 2 with the above conditions and patches or not where I was able to
figure it out myself. I don't really understand why you are opposed to
these questions.
