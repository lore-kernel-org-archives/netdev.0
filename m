From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: Do not account for sizeof(struct sk_buff) in estimated
 rwnd
Date: Tue, 20 Dec 2011 13:01:13 -0500
Message-ID: <4EF0CD69.9000602@hp.com>
References: <CAPgLHd-JL8cjMBSqO5Lc5nEt42zqj8qAn+qHaM35HTmnhOHg7w@mail.gmail.com> <20111220093910.GB21801@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Wei Yongjun <weiyj.lk@gmail.com>, linux-sctp@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:15485 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab1LTSBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 13:01:35 -0500
In-Reply-To: <20111220093910.GB21801@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/20/2011 04:39 AM, Thomas Graf wrote:
> On Tue, Dec 20, 2011 at 01:00:48PM +0800, Wei Yongjun wrote:
>> I saw you discussed this with Vlad in old mail:
>>      http://www.spinics.net/lists/linux-sctp/msg01365.html
>>
>> You said you will update patch to include a per packet overhead,
>> but it does not include in this patch, what's wrong with in?
>
> It's not possible because upon retransmission of a chunk we need
> to readd the overhead to the rwnd. There is no longer a reference
> to a packet so we can't know how much to add. This explanation is
> also in the original mail thread.
>


Right.  The original patches were done to work around the problem of
leftover rwnd when socket buffer is exhausted and they didn't really
address the problem sufficiently.  It was still possible to reach that
condition.  Some subsequent patches added support to address this issue
a different way.  As a result, I think this revert is just fine.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad
