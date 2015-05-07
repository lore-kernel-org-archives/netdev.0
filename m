From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v5 2/2] pktgen: introduce xmit_mode '<start_xmit|netif_receive>'
Date: Thu, 07 May 2015 19:11:58 +0200
Message-ID: <554B9CDE.1050703@iogearbox.net>
References: <20150507143329.8534.49710.stgit@ivy> <20150507143500.8534.4435.stgit@ivy> <554B9293.2070702@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54828 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbbEGRMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 13:12:16 -0400
In-Reply-To: <554B9293.2070702@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2015 06:28 PM, Alexei Starovoitov wrote:
> On 5/7/15 7:35 AM, Jesper Dangaard Brouer wrote:
>> From: Alexei Starovoitov <ast@plumgrid.com>
>>
>> Introduce xmit_mode 'netif_receive' for pktgen which generates the
>> packets using familiar pktgen commands, but feeds them into
>> netif_receive_skb() instead of ndo_start_xmit().
>>
>> Default mode is called 'start_xmit'.
> ...
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>
>> ---
>> v4->v5:
>> - Rename xmit_mode's <start_xmit|netif_receive>
>> - Save one branch when calling eth_type_trans(), noticed by Alex Duyck
>
> looks good to me. Thanks a lot.
>
> btw, I've started to work on a patch on top of this one that allows
> multiple pktgen threads to submit into the same netdev.
> I've used it to stress test removal of spin_lock in ingress qdisc.
> The idea is to add another 'name' parameter to command:
> 'add_device name dev'
> 'name' will be used to identify this pktgen thread in /proc
> and 'dev' used as target net_device.
> I think it will be useful for start_xmit testing as well.
> I wonder why it wasn't done earlier? The queue configuration is
> already supported.

You mean other than below commit (iow independant of queue mapping)?

commit e6fce5b916cd7f7f79b2b3e53ba74bbfc1d7cf8b
Author: Robert Olsson <robert.olsson@its.uu.se>
Date:   Thu Aug 7 02:23:01 2008 -0700

     pktgen: multiqueue etc.
