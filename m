From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 21:18:40 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222113240.24323-100000@shell.cyberus.ca>
References: <3DB5F605.1010507@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB5F605.1010507@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 22 Oct 2002, Ben Greear wrote:

> Actually, with the changes the way they are, if you have a backlog value
> of 300, and the first NAPI driver reads 300 packets, then all the rest of the
> NAPI drivers will just throw away packets because the max-backlog has
> already been hit (if I understand things correctly).
>

The 300 is shared amongst all the drivers which have something on their
rx DMA. This is done on a roundrobin fashion.
Also all the drivers which are non-napi are given the same quota.

> If we make the backlog big enough to handle a large burst of incomming
> traffic w/out dropping them, then the first NAPI driver can hog a very
> large amount of CPU because its budget is now huge.  The rest of
> the devices in the poll loop will not be serviced in time, and will
> drop packets (I saw this when testing out the 4-port tulip driver with
> the NAPI patch).
>

I think you misunderstood. Look at the dev->weight.

cheers,
jamal
