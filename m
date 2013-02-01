From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] net: remove redundant checking for sock timer state
Date: Fri, 1 Feb 2013 14:32:29 +0800
Message-ID: <510B617D.1050004@windriver.com>
References: <1359697980-28613-1-git-send-email-ying.xue@windriver.com> <20130201.010946.584437309593473452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:61692 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318Ab3BAGb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 01:31:58 -0500
In-Reply-To: <20130201.010946.584437309593473452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Fri, 1 Feb 2013 13:53:00 +0800
> 
>> It's unnecessary to check whether the sock timer to be stopped is
>> pending or not in sk_stop_timer() as del_timer() will do the same
>> thing later.
>>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> 
> Did it even occur to you that when this code was written, this
> "redundant" testing was also redundant, but that it might have been
> done on purpose?
> 

Sorry, at least I really cannot figure out the redundant test has some 
special purpose. However, it seems I found some clues which may prove 
the "redundant" test is really redundant:

The sk_stop_timer() function is never changed after kernel initial git 
repository is built. But calling timer_pending() in del_timer() is 
involved by 55c888d6 commit.


Regards,
Ying


> If you are going to change this code, you must understand why it was
> written this way, because that is the only context in which you will
> be able to justify removing the test.
> 
> Otherwise I'm ignoring this patch.
> 

Hi Dave,
