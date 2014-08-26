From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: Don't allocate rds_sock on stack
Date: Tue, 26 Aug 2014 08:29:06 -0700 (PDT)
Message-ID: <20140826.082906.614050508596912545.davem@davemloft.net>
References: <1408926755-12277-1-git-send-email-broonie@kernel.org>
	<20140825.125740.214306460002405867.davem@davemloft.net>
	<20140826065409.GT17528@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933044AbaHZP3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 11:29:09 -0400
In-Reply-To: <20140826065409.GT17528@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Tue, 26 Aug 2014 07:54:09 +0100

> On Mon, Aug 25, 2014 at 12:57:40PM -0700, David Miller wrote:
>> From: Mark Brown <broonie@kernel.org>
> 
>> > From: Mark Brown <broonie@linaro.org>
> 
>> > struct rds_sock is rather large ausing the following warning in an ARM
>> > allmodconfig:
> 
>> > net/rds/iw_rdma.c:200:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
>> > Fix this by dynamically allocating struct rds_sock in rds_iw_update_cm_id
>> > instead of allocating it on the stack.
> 
>> > Signed-off-by: Mark Brown <broonie@linaro.org>
> 
>> I'd like you to fix this differently.  Creating pseudo instances of
>> objects, and partially initializing it, just to satisfy an interface
>> is always a really bad sign.
> 
>> Create a key structure argument for rds_iw_get_device() and initialize that
>> and pass it in instead, update the other caller similarly.
> 
> I agree that the existing code looks like it could be improved even more
> but please bear in mind that I'm just looking for a clean build (we've
> got less than 20 warnings in allmodconfig including staging at the
> minute) rather than actively working on this code in particular - I've
> no ability to do more than build testing here.

I understand that, but please fix this bug properly.
