From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] netlink: preserve netlink pkt_type on dev_queue_xmit_nit
Date: Sun, 13 Apr 2014 20:12:34 +0200
Message-ID: <534AD392.8050302@redhat.com>
References: <1397240729-32667-1-git-send-email-dborkman@redhat.com> <20140412.170205.763190722974019268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darkjames-ws@darkjames.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29265 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754558AbaDMSMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2014 14:12:41 -0400
In-Reply-To: <20140412.170205.763190722974019268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2014 11:02 PM, David Miller wrote:
...
> I really don't like the idea of treating some packets that go out of
> dev_queue_xmit_nit() as one type, and others of another type.

Understood and agreed, fwiw, I was fighting with myself and don't really
like it either.

> Because dammit, if the packet is going through this function it very
> much is PACKET_OUTGOING.
>
> It's outgoing to your special netlink tap device in this case right?

Yep; it's of course still outgoing, just tells more specific if it has
been sent from user space or kernel space, thus it preserves PACKET_USER
and PACKET_KERNEL (as otherwise overwritten -- it's for user space to
tell from which direction the skb has been sent). I'll think about it
further and already have some other ideas to try out that are hopefully
more generic/acceptable. Anyway, thanks for your feedback.
