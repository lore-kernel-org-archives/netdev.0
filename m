From: Jianjun Kong <jianjun@zeuux.org>
Subject: Re: [PATCH] nets: fix problem of using lock
Date: Tue, 11 Nov 2008 09:34:21 +0800
Message-ID: <20081111013421.GA7091@ubuntu>
References: <20081106104103.GA29787@ubuntu> <20081110.133515.130695626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:61139 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752817AbYKKBeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 20:34:03 -0500
Content-Disposition: inline
In-Reply-To: <20081110.133515.130695626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2008 at 01:35:15PM -0800, David Miller wrote:
>From: Jianjun Kong <jianjun@zeuux.org>
>Date: Thu, 6 Nov 2008 18:41:03 +0800
>
>> net/core/skbuff.c: void skb_queue_purge(struct sk_buff_head *list)
>> 
>> This function should takes the the list lock, because the operation to
>> this list shoule be atomic. And __skb_queue_purge()  (in
>> include/linux/skbuff.c) real delete the buffers in the list.
>> 
>> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
>
>No, this function is fine.  skb_dequeue() takes the lock so
>there cannot be any list corruption.
>
>And this function is called in contexts where the caller knows
>that no new packets can be added to the list (closing a socket,
>shutting down a device, etc.)  And even if new packets could
>appear, taking the lock over the entire function would not
>help that problem.
>
>In fact, I suspect that many if not all skb_queue_purge() callers
>can be converted to use __skb_queue_purge().

Thanks, I've known :-)

-- 
Jianjun Kong @_@ Happy Hacking
Homepage: http://kongove.cn/
Gtalk: kongjianjun@gmail.com
