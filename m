From: Vasily Averin <vvs@parallels.com>
Subject: Re: [PATCH v2] ipv4: dst_entry leak in ip_append_data()
Date: Wed, 15 Oct 2014 15:31:37 +0400
Message-ID: <543E5B19.2080200@parallels.com>
References: <543CAD2A.3070701@parallels.com>	 <1413348385.12304.0.camel@edumazet-glaptop2.roam.corp.google.com>	 <543E1AAF.9050601@parallels.com> <1413365433.12304.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16421 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbaJOLdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 07:33:20 -0400
In-Reply-To: <1413365433.12304.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.10.2014 13:30, Eric Dumazet wrote:
> On Wed, 2014-10-15 at 10:56 +0400, Vasily Averin wrote:
>> On 15.10.2014 08:46, Eric Dumazet wrote:
>>> On Tue, 2014-10-14 at 08:57 +0400, Vasily Averin wrote:
>>>> v2: adjust the indentation of the arguments __ip_append_data() call
>>>>
>>>> Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")
>>>>
>>>> If sk_write_queue is empty ip_append_data() executes ip_setup_cork()
>>>> that "steals" dst entry from rt to cork. Later it calls __ip_append_data()
>>>> that creates skb and adds it to sk_write_queue.
>>>>
>>>> If skb was added successfully following ip_push_pending_frames() call
>>>> reassign dst entries from cork to skb, and kfree_skb frees dst_entry.
>>>>
>>>> However nobody frees stolen dst_entry if skb was not added into sk_write_queue.
>>>
>>> I thought this was done by ip_flush_pending_frames() ?
>>
>> Take look at ip_send_unicast_reply():
> 
> So maybe the bug is here ?

Thank you, I'll remake my patch.
