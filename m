From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 29 Nov 2004 20:27:57 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0411292007080.18143@hibernia.jakma.org>
References: <OF7E76C3BE.B1D182D3-ONC1256F5B.005B3E84-C1256F5B.005BB584@de.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Spatzier <thomas.spatzier@de.ibm.com>
In-Reply-To: <OF7E76C3BE.B1D182D3-ONC1256F5B.005B3E84-C1256F5B.005BB584@de.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Nov 2004, Thomas Spatzier wrote:

> Yes, for the examples you mentioned the app should better be 
> notified. However, AFAICS, there are no such notification 
> mechanisms on a per-packet basis implemented in the kernel. And I 
> doubt that they are going to be implemented.

We do get notified. We get a netlink interface update with 
unset IFF_RUNNING from the interface flags.

However, it can take time before zebra gets to read it, and further 
time before zebra sends its own interface update to protocol daemons, 
and further time before they might get to read and update their own 
interface state. By which time those daemons may have sent packets 
down those interfaces (which packets may become invalid before link 
becomes back, but which still will be sent and hence which 
potentially could disrupt routing).

Ideally, we should be notified synchronously (EBUFS?) or if thats not 
possible, packet should be dropped (see my below presumption though).

The other solution is some means for a daemon to be able flush queues 
for a specific interface. (but thats a bit ugly).

> Good suggestion, if anyone has an interesting and feasible solution 
> I will be happy to integrate it. So far, however, it don't see one 
> and I would point people being worried about lost packets to TCP.

Surely TCP already was able to take care of retransmits? I'm not 
familiar with Linux internals, but how did TCP cope with the previous 
driver behaviour? (I get the vague impression that we're talking 
about a driver specific buffer here, rather than the applications 
socket buffer - is that correct?).

Jeff, David, enlighten us please! :)

> Regards,
> Thomas.

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
I can't understand why people are frightened of new ideas.  I'm frightened
of the old ones.
 		-- John Cage
