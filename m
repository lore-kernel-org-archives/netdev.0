From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Subject: single process receives own frames due to PACKET_MMAP
Date: Mon, 06 Jan 2014 23:58:01 +0100
Message-ID: <52CB34F9.6020906@aimvalley.nl>
References: <52B4465E.2090904@aimvalley.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, uaca@alumni.uv.es
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mika.eatserver.nl ([195.20.9.75]:54747 "EHLO mika.eatserver.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757060AbaAFW7P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 17:59:15 -0500
In-Reply-To: <52B4465E.2090904@aimvalley.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Our application uses raw AF_PACKET socket to send and receive
on one particular ethernet interface.

Recently we started using PACKET_MMAP (TPACKET_V2). This makes
the Appl use a TX socket and a RX socket.
Both sockets are bound to the same (eth) interface. I noticed
the RX socket receives all frames that are sent via the
TX socket (same process, different thread). This I do not want.

I know it is supposed to happen for different processes
(otherwise wireshark won't work), but I did not expect it to
happen for one single process (with different threads).

I can filter them out in user-space (PACKET_OUTGOING)
or via kernel packet filter (SO_ATTACH_FILTER), but performance is
critical.

I wonder whether this (PACKET_MMAP) behaviour is OK.

It did not happen before (with a non-PACKET_MMAP AF_PACKET socket
which was used by both threads of the same Appl process). So
why is it happening now ?
I'd say it makes no sense to make the same process receive its
own transmitted frames on that same interface (unless its lo).

If I'm not doing something wrong, this means this behaviour
causes my CPU to be loaded much more (since all transmitted frames
have to be filtered out).

Let me know what you think.

thanks,
Norbert van Bolhuis
