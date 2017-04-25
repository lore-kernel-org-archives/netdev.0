From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: Network cooling device and how to control NIC speed on thermal
 condition
Date: Tue, 25 Apr 2017 14:45:01 +0100
Message-ID: <20170425144501.0cfe27a5@lxorguk.ukuu.org.uk>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I am looking on Linux thermal framework and on how to cool down the
> system effectively when it hits thermal condition. Already existing
> cooling methods cpu_cooling and clock_cooling are good. However, I
> wanted to go further and dynamically control also a switch ports'
> speed based on thermal condition. Lowering speed means less power,
> less power means lower temp.
> 
> Is there any in-kernel interface to configure switch port/NIC from other driver?

No but you can always hook that kind of functionality to the thermal
daemon. However I'd be careful with your assumptions. Lower speed also
means more time active.

https://github.com/01org/thermal_daemon

For example if you run a big encoding job on an atom instead of an Intel
i7, the atom will often not only take way longer but actually use more
total power than the i7 did.

Thus it would often be far more efficient to time synchronize your
systems, batch up data on the collecting end, have the processing node
wake up on an alarm, collect data from the other node and then actually
go back into suspend.

Modern processors are generally very good in idle state (less so
sometimes the platform around them) so trying to lower speeds may
actually be the wrong thing to do, versus say trying to batch up activity
so that you handle a burst and then sleep the entire platform.

It also makes sense to keep policy like that mostly user space - because
what you do is going to be very device specific - eg with things like
dimming the screen, lowering the wifi power, pausing some system
services, pausing battery charge etc.

Now at platform design time there are some interesting trade offs between
100Mbit and 1Gbit ethernet although less so than there used to be 8)

Alan
