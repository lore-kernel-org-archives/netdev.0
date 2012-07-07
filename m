From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] asix: avoid copies in tx path
Date: Sat, 07 Jul 2012 16:27:36 -0700 (PDT)
Message-ID: <20120707.162736.1854416247572265857.davem@davemloft.net>
References: <1341498661.2583.4162.camel@edumazet-glaptop>
	<CACVXFVOYgVG5cZE8YPn2z6_xu5akLvUURJ3_pE4Stbh7U8L_AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, allan@asix.com.tw, trond@chromium.org,
	grundler@chromium.org
To: ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab2GGX1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 19:27:37 -0400
In-Reply-To: <CACVXFVOYgVG5cZE8YPn2z6_xu5akLvUURJ3_pE4Stbh7U8L_AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <ming.lei@canonical.com>
Date: Fri, 6 Jul 2012 09:16:32 +0800

> On Thu, Jul 5, 2012 at 10:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> I noticed excess calls to skb_copy_expand() or memmove() in asix driver.
>>
>> This driver needs to push 4 bytes in front of frame (packet_len)
>> and maybe add 4 bytes after the end (if padlen is 4)
>>
>> So it should set needed_headroom & needed_tailroom to avoid
>> copies. But its not enough, because many packets are cloned
>> before entering asix_tx_fixup() and this driver use skb_cloned()
>> as a lazy way to check if it can push and put additional bytes in frame.
>>
>> Avoid skb_copy_expand() expensive call, using following rules :
>>
>> - We are allowed to push 4 bytes in headroom if skb_header_cloned()
>>   is false (and if we have 4 bytes of headroom)
>>
>> - We are allowed to put 4 bytes at tail if skb_cloned()
>>   is false (and if we have 4 bytes of tailroom)
>>
>> TCP packets for example are cloned, but skb_header_release()
>> was called in tcp stack, allowing us to use headroom for our needs.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Tested-by: Ming Lei <ming.lei@canonical.com>

Applied, thanks Eric.
