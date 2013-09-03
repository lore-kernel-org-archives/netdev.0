From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour
 discovery messages
Date: Tue, 03 Sep 2013 11:42:00 -0600
Message-ID: <52261F68.70907@wwwdotorg.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch> <52261A12.3060203@wwwdotorg.org> <20130903172736.GB21729@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:41006 "EHLO
	avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754676Ab3ICRmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 13:42:04 -0400
In-Reply-To: <20130903172736.GB21729@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 11:27 AM, Hannes Frederic Sowa wrote:
> On Tue, Sep 03, 2013 at 11:19:14AM -0600, Stephen Warren wrote:
>> On 09/03/2013 05:37 AM, Thomas Graf wrote:
>>> Allocating skbs when sending out neighbour discovery messages
>>> currently uses sock_alloc_send_skb() based on a per net namespace
>>> socket and thus share a socket wmem buffer space.
>>>
>>> If a netdevice is temporarily unable to transmit due to carrier
>>> loss or for other reasons, the queued up ndisc messages will cosnume
>>> all of the wmem space and will thus prevent from any more skbs to
>>> be allocated even for netdevices that are able to transmit packets.
>>>
>>> The number of neighbour discovery messages sent is very limited,
>>> use of alloc_skb() bypasses the socket wmem buffer size enforcement
>>> while the manual call to skb_set_owner_w() maintains the socket
>>> reference needed for the IPv6 output path.
>>>
>>> This patch has orginally been posted by Eric Dumazet in a modified
>>> form.
>>
>> Tested-by: Stephen Warren <swarren@nvidia.com>
>>
>> Although I do note something slightly odd:
>>
>> next-20130830 had an issue, and reverting V1 of this patch solved it.
>>
>> However, in next-20130903, if I revert the revert of V1 of this patch, I
>> don't see any issue; it appears that the problem was some interaction
>> between V1 of this patch and something else in next-20130830.
>>
>> Either way, this patch doesn't seem to introduce any issue when applied
>> on top of either next-20130830 with V1 reverted, or on top of
>> next-20130903, so it's fine.
> 
> Could either of you run the v1 version of the patch with CONFIG_PROVE_LOCKING
> enabled? I also do think there is some side-effect we don't understand yet.

I don't see any extra messages from PROVE_LOCKING related to networking.
There is a single extra message from inside the audio driver, but that's
not networking-related at all.
