From: "David S. Miller" <davem@redhat.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 14:29:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911142906.74d9dfe5.davem@redhat.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
	<3F60CA6D.9090503@pobox.com>
	<3F60D0F3.8080006@candelatech.com>
	<20030911131219.0ab8dfdd.davem@redhat.com>
	<3F60DDCC.5020906@candelatech.com>
	<20030911140746.4f0384a1.davem@redhat.com>
	<3F60E947.4090005@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F60E947.4090005@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2003 14:29:43 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Thanks for that clarification.  Is there no way to tell
> at 'sendto' time that the buffers are over-full, and either
> block or return -EBUSY or something like that?

The TX queue state can change by hundreds of packets by
the time we are finished making the "decision", also how would
you like to "wake" up sockets when the TX queue is liberated.
That extra overhead and logic would be wonderful for performance.

No, this is all nonsense.  Packet scheduling and queueing is
an opaque layer to all the upper layers.  It is the only sensible
design.

IP transmit is black hole that may drop packets at any moment,
any datagram application not prepared for this should be prepared
for troubles or choose to move over to something like TCP.

I listed even a workaround for such stupid UDP apps, simply limit
their socket send queue limits.
