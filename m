From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 29 Nov 2004 16:30:23 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0411291602330.18143@hibernia.jakma.org>
References: <OF773C347F.92E998FA-ONC1256F5B.0056F87D-C1256F5B.0057A78F@de.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261754AbUK2QbY@vger.kernel.org>
To: Thomas Spatzier <thomas.spatzier@de.ibm.com>
In-Reply-To: <OF773C347F.92E998FA-ONC1256F5B.0056F87D-C1256F5B.0057A78F@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Nov 2004, Thomas Spatzier wrote:

> Has there been any outcome on the discussion about whether or not a 
> device driver should drop packets when the cable is disconnected?

There hasnt.

> It seems that from the zebra point of view, as Paul wrote, it would 
> be better to not block sockets by queueing up packets when there is 
> no cable connection.

I'd prefer either to get ENOBUFS or to have kernel drop the packet - 
we're privileged apps writing to raw sockets and/or with IP_HDRINCL, 
the kernel should assume we know what we're doing (cause if we dont, 
there's far /worse/ we could do than send packets to an 
effective /dev/null).

> I do also think that it does not make sense to keep packets in the 
> queue and then send those packets when the cable is plugged in 
> again after a possibly long time.

Well, if the kernel is going to queue these packets without notifying 
us, we absolutely *must* have some way to flush those queues. Sending 
stale packets many minutes after the application generated them could 
have serious consequences for routing (eg, think sending RIP, IPv4 
IRDP or v6 RAs which are no longer valid - client receives them and 
installs routes which are long invalid and loses connectivity to some 
part of the network).

So even if we moved to socket/interface, we still need some way to 
tell kernel to flush a socket when we receive link-down over netlink 
later.

Not trying to queue on sockets where app has no expectation of 
reliability in first place would be even better ;)

> There are protocols like TCP that handle packet loss anyway.

Yes.

I'd be very interested to hear advice from the kernel gurus (eg "god, 
dont be so stupid, do xyz in your application instead"). We can 
accomodate whatever kernel wants as long as its workable.

> Regards,
> Thomas.

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
You will pay for your sins.  If you have already paid, please disregard
this message.
