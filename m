From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Drop budget parameter from NAPI polling call
 hierarchy
Date: Tue, 29 Sep 2015 13:48:46 -0700 (PDT)
Message-ID: <20150929.134846.1031290048722134936.davem@davemloft.net>
References: <20150922215049.3088.32475.stgit@ahduyck-vm-fedora22>
	<20150926.223631.507670918270362716.davem@davemloft.net>
	<560874B0.1080903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbbI2Usr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 16:48:47 -0400
In-Reply-To: <560874B0.1080903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sun, 27 Sep 2015 15:58:56 -0700

> On 09/26/2015 10:36 PM, David Miller wrote:
>> From: Alexander Duyck <aduyck@mirantis.com>
>> Date: Tue, 22 Sep 2015 14:56:08 -0700
>>
>>> Rather than carry around a value of budget that is 0 or less we can
>>> instead
>>> just loop through and pass 0 to each napi->poll call.  If any driver
>>> returns a value for work done that is non-zero then we can report that
>>> driver and continue rather than allowing a bad actor to make the
>>> budget
>>> value negative and pass that negative value to napi->poll.
>> Unfortunately we have drivers that won't do any TX work if the budget
>> is zero.
> 
> Well that is what we are doing right now.  The fact is the call starts
> out with a budget of 0, and it is somewhat hidden from the call since
> the budget is assigned a value of 0 in netpoll_poll_dev. That is one
> of the things I was wanting do address because that is clear as mud
> from looking at poll_one_napi.  Based on the code you would assume
> budget starts out as a non-zero value and it doesn't.

I see, thanks for explaining.
