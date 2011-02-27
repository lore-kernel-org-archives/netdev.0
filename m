From: Albert Cahalan <acahalan@gmail.com>
Subject: txqueuelen has wrong units; should be time
Date: Sun, 27 Feb 2011 00:44:01 -0500
Message-ID: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(thinking about the bufferbloat problem here)

Setting txqueuelen to some fixed number of packets
seems pretty broken if:

1. a link can vary in speed (802.11 especially)

2. a packet can vary in size (9 KiB jumbograms, etc.)

3. there is other weirdness (PPP compression, etc.)

It really needs to be set to some amount of time,
with the OS accounting for packets in terms of the
time it will take to transmit them. This would need
to account for physical-layer packet headers and
minimum spacing requirements.

I think it could also account for estimated congestion
on the local link, because that effects the rate at which
the queue can empty. An OS can directly observe this
on some types of hardware.

Nanoseconds seems fine; it's unlikely you'd ever want
more than 4.2 seconds (32-bit unsigned) of queue.

I guess there are at least 2 queues of interest, with the
second one being under control of the hardware driver.
Having the kernel split the max time as appropriate for
the hardware seems nicest.
