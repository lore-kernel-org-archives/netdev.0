From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: single process receives own frames due to PACKET_MMAP
Date: Tue, 07 Jan 2014 10:32:01 +0100
Message-ID: <52CBC991.8030701@redhat.com>
References: <52B4465E.2090904@aimvalley.nl> <52CB34F9.6020906@aimvalley.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	uaca@alumni.uv.es, Jesper Dangaard Brouer <jbrouer@redhat.com>
To: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470AbaAGJdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 04:33:17 -0500
In-Reply-To: <52CB34F9.6020906@aimvalley.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2014 11:58 PM, Norbert van Bolhuis wrote:
>
> Our application uses raw AF_PACKET socket to send and receive
> on one particular ethernet interface.
>
> Recently we started using PACKET_MMAP (TPACKET_V2). This makes
> the Appl use a TX socket and a RX socket.
> Both sockets are bound to the same (eth) interface. I noticed
> the RX socket receives all frames that are sent via the
> TX socket (same process, different thread). This I do not want.
>
> I know it is supposed to happen for different processes
> (otherwise wireshark won't work), but I did not expect it to
> happen for one single process (with different threads).
>
> I can filter them out in user-space (PACKET_OUTGOING)
> or via kernel packet filter (SO_ATTACH_FILTER), but performance is
> critical.
>
> I wonder whether this (PACKET_MMAP) behaviour is OK.

For your use-case, we recently introduced in d346a3fae3ff1
("packet: introduce PACKET_QDISC_BYPASS socket option") a
bypass of dev_queue_xmit() (that internally invokes
dev_queue_xmit_nit()).

> It did not happen before (with a non-PACKET_MMAP AF_PACKET socket
> which was used by both threads of the same Appl process). So
> why is it happening now ?

Can you elaborate a bit on which kernel versions that behaviour
changed?

> I'd say it makes no sense to make the same process receive its
> own transmitted frames on that same interface (unless its lo).
>
> If I'm not doing something wrong, this means this behaviour
> causes my CPU to be loaded much more (since all transmitted frames
> have to be filtered out).
>
> Let me know what you think.
>
> thanks,
> Norbert van Bolhuis
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
