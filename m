From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/2] tipc: avoid possible deadlock while remove link_timeout()
Date: Fri, 9 Aug 2013 11:38:07 +0800
Message-ID: <5204641F.60009@huawei.com>
References: <520376BA.5040509@huawei.com> <5204567E.2050805@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7568 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967470Ab3HIDiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 23:38:20 -0400
In-Reply-To: <5204567E.2050805@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/9 10:39, Ying Xue wrote:
> On 08/08/2013 06:45 PM, Ding Tianhong wrote:

>>
>> The problem is that the tipc_link_delete() will cancel the timer l_ptr->timer when
>> the b_ptr->lock is hold, but the l_ptr->timer still call b_ptr->lock to finish the
>> work, so the dead lock occurs.
>>
> 
> I guess the issue would disappear if you apply below patch:
> 
> http://article.gmane.org/gmane.network.tipc.general/4380
> 
> And the patch will be submitted into net-next tree soon.
> 
> Regards,
> Ying
> 

yes, I test the patch and fix the 1/2 problem, but the 2/2 problem still occurs, if 
the http://article.gmane.org/gmane.network.tipc.general/4380 and queue for stable, I will resend
2/2 patch again and cancel the 1/2 patch.
