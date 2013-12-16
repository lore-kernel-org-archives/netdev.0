From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 2/3] packet: fill the gap of TPACKET_ALIGNMENT with
 zeros
Date: Mon, 16 Dec 2013 13:55:43 +0100
Message-ID: <52AEF84F.1000604@redhat.com>
References: <87ob4h6wq1.wl%atzm@stratosphere.co.jp> <52AED170.9020604@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7491@saturn3.aculab.com> <52AED46B.3090601@redhat.com> <87k3f56k8t.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753817Ab3LPMzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 07:55:54 -0500
In-Reply-To: <87k3f56k8t.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 01:41 PM, Atzm Watanabe wrote:
> At Mon, 16 Dec 2013 11:22:35 +0100,
> Daniel Borkmann wrote:
>>
>> On 12/16/2013 11:16 AM, David Laight wrote:
>>>>> +		memset(h.h2->tp_padding, 0,
>>>>> +		       hdrlen - offsetof(struct tpacket2_hdr, tp_padding));
>>>
>>> What is wrong with 'sizeof h.h2->tp_padding' ?
>>> The compiler will probably inline the memset into a couple of word
>>> sized writes of zero - probably not measurable.
>>> Not zeroing them might be leaking kernel memory contents (depends
>>> where the memory came from - might just be stale packet data).
>>
>> The ring buffer memory we're operating on comes from mmap(2) btw.
>
> Thank you for comments.
> In struct tpacket2_hdr, it seems that a padding member was really
> zeroing to fix information leak on commit
> 13fcb7bd322164c67926ffe272846d4860196dc6 ("af_packet: prevent information leak").
> So next time I'll try to zero tp_padding using sizof(h.h2->tp_padding)
> David proposed.  If you have any thoughts on this please share it with me.

Yep, 13fcb7bd was for struct tpacket_auxdata structure in packet_recvmsg()
that sits on the stack and copied uninitialized data to user space. But,
okay, lets go with the memset().
