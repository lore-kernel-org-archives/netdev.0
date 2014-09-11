From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH net-next 2/2] mac80211: Resolve sk_refcnt/sk_wmem_alloc
 issue in wifi ack path
Date: Thu, 11 Sep 2014 11:38:22 +0200
Message-ID: <54116D8E.20308@broadcom.com>
References: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>	 <20140910220536.23225.92956.stgit@ahduyck-bv4.jf.intel.com> <1410419198.1825.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:2794 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbaIKJi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 05:38:28 -0400
In-Reply-To: <1410419198.1825.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/14 09:06, Johannes Berg wrote:
> On Wed, 2014-09-10 at 18:05 -0400, Alexander Duyck wrote:
>> There is a possible issue with the use, or lack thereof of sk_refcnt and
>> sk_wmem_alloc in the wifi ack status functionality.
>>
>> Specifically if a socket were to request acknowledgements, and the socket
>> were to have sk_refcnt drop to 0 resulting in it waiting on sk_wmem_alloc
>> to reach 0 it would be possible to have sock_queue_err_skb orphan the last
>> buffer, resulting in __sk_free being called on the socket.  After this the
>> buffer is enqueued on sk_error_queue, however the queue has already been
>> flushed resulting in at least a memory leak, if not a data corruption.
>
> Oh. Thanks :-)

Hi Alexander,

So why is this only an issue in wifi ack path. The sock_queue_err_skb() 
does not mention the caller should hold a sock reference. This seems 
entirely an issue of the sock_queue_err_skb() function itself so why not 
do sk_hold/sk_put within that function. Does it impose too much overhead?

Regards,
Arend
