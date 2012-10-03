From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Wed, 03 Oct 2012 14:48:36 -0400 (EDT)
Message-ID: <20121003.144836.924664278405838209.davem@davemloft.net>
References: <1349281090-10013-20-git-send-email-peter.senna@gmail.com>
	<20121003092508.6a7da662@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.senna@gmail.com, mlindner@marvell.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803Ab2JCSsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 14:48:39 -0400
In-Reply-To: <20121003092508.6a7da662@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 3 Oct 2012 09:25:08 -0700

> On Wed,  3 Oct 2012 18:18:10 +0200
> Peter Senna Tschudin <peter.senna@gmail.com> wrote:
> 
>> From: Peter Senna Tschudin <peter.senna@gmail.com>
>> 
>> Convert a nonnegative error return code to a negative one, as returned
>> elsewhere in the function.
>> 
>> A simplified version of the semantic match that finds this problem is as
>> follows: (http://coccinelle.lip6.fr/)
>> 
>> // <smpl>
>> (
>> if@p1 (\(ret < 0\|ret != 0\))
>>  { ... return ret; }
>> |
>> ret@p1 = 0
>> )
>> ... when != ret = e1
>>     when != &ret
>> *if(...)
>> {
>>   ... when != ret = e2
>>       when forall
>>  return ret;
>> }
>> // </smpl>
>> 
>> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
>> 
> 
> Thanks for looking into these kind of problems. The contents
> of the patch are correct, but the automated commit message is useless.
> You shouldn't just blindly say what the automated
> script was looking for, you should describe what the bug is so that evaluators
> can decide what the impact is and if it should be backported to stable
> and vendor kernels.

Agreed, I like seeing the checker script but I had that the entire
commit message is automated and has no human analysis or somments.
