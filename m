From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: kmemcheck detected possible information leak to userspace?
Date: Tue, 1 Jul 2008 12:52:53 +0200
Message-ID: <19f34abd0807010352t264fda16g826912a857e88140@mail.gmail.com>
References: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com>
	 <20080701102459.GB30248@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:10439 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbYGAKwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 06:52:53 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1956856wfd.4
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 03:52:53 -0700 (PDT)
In-Reply-To: <20080701102459.GB30248@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 1, 2008 at 12:25 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>> $ addr2line -e vmlinux -i c05325c7 # packet_recvmsg
>> net/packet/af_packet.c:1093
>
> This gives:
>        copied = skb->len;
>        if (copied > len)
>        {
>                copied=len;
>                msg->msg_flags|=MSG_TRUNC;
>        }
>
>        err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
>
> So everything looks ok, but driver could setup skb->len and/or
> skb->data_len to be slightly more than it placed data. Does
> above 'uuuu' bytes are at the end of the skb->data?

In fact I didn't give you the first such message. The first one looks like this:

kmemcheck: Caught 32-bit read from uninitialized memory (c72da052)
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu
                  ^

(with a similar stacktrace).

The u means uninitialized. So it seems not to be just the end. But I
am not sure where the end of the buffer is anyway.

But there is one thing I forgot: Is this memory initialized by DMA? If
so, the warning is bogus and I will go hide in shame.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
