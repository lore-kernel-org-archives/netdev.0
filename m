From: Ricardo C Gonzalez <ricardoz@us.ibm.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 16:47:43 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFAFA77EE1.3E4E4085-ON85256D9E.00777520-86256D9E.0077947E@us.ibm.com>
References: <20030911142906.74d9dfe5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030911142906.74d9dfe5.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




>IP transmit is black hole that may drop packets at any moment,
>any datagram application not prepared for this should be prepared
>for troubles or choose to move over to something like TCP.


As I said before, please do not make this a UDP issue. The data I sent out
was taken using a TCP_STREAM test case. Please review it.

regards,
----------------------------------------------------------------------------------

***  ALWAYS THINK POSITIVE ***

Rick Gonzalez
IBM Linux Performance Group
Building: 905    Office: 7G019
Phone: (512) 838-0623

"David S. Miller" <davem@redhat.com> on 09/11/2003 04:29:06 PM

To:    Ben Greear <greearb@candelatech.com>
cc:    jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
       Ricardo C Gonzalez/Austin/IBM@ibmus
Subject:    Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default



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
