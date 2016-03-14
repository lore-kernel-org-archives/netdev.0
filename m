From: Andrzej Hajda <a.hajda@samsung.com>
Subject: Re: [PATCH] kcm: fix variable type
Date: Mon, 14 Mar 2016 07:45:44 +0100
Message-ID: <56E65E18.1050907@samsung.com>
References: <1457679075-22094-1-git-send-email-a.hajda@samsung.com>
 <20160311.114442.1933815095495449507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.w1.samsung.com ([210.118.77.12]:22322 "EHLO
	mailout2.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbcCNGqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 02:46:03 -0400
In-reply-to: <20160311.114442.1933815095495449507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2016 05:44 PM, David Miller wrote:
> From: Andrzej Hajda <a.hajda@samsung.com>
> Date: Fri, 11 Mar 2016 07:51:15 +0100
>
>> Function skb_splice_bits can return negative values, its result should
>> be assigned to signed variable to allow correct error checking.
>>
>> The problem has been detected using patch
>> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci.
>>
>> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> Since skb_splice_bits() returns an 'int', that would be a more appropriate
> type to use here.
>
> Thank you.
>
>
On the other side kcm_splice_read use this local var as return variable,
and the return type is ssize_t.

Digging deeper it looks like:
ssize_t kcm_splice_read(...) returns result of
int skb_splice_bits(...) which returns result of
ssize_t splice_cb(...) callback.

It looks code is somehow inconsistent, but maybe there are other reasons
which I am not aware of.

Regards
Andrzej
