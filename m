From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 13:41:28 -0800
Message-ID: <370106E9-5C39-4917-AE74-2ED5E376DA11@holtmann.org>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com> <20140102.034653.1968429090467668489.davem@davemloft.net> <CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:38237 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaABVld convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 16:41:33 -0500
In-Reply-To: <CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

> Is anybody actually really using or maintaining irda any more? Because
> nothing seems to work. I think the following is *supposed* to work as
> a way to emulate having two irda dongles without actually having the
> hardware:
> 
> - in terminal 1:
> 
>        socat PTY,link=/tmp/ttyS0 PTY,link=/tmp/ttyS1
> 
> - terminal 2:
> 
>        irattach $(readlink /tmp/ttyS0) -s
>        irattach $(readlink /tmp/ttyS1) -s
> 
> - in terminal 3:
> 
>        echo "Duh" > /dev/ircomm0
> 
> - in terminal 4:
> 
>        cat /dev/ircomm1
> 
> (expecting to see "Duh" in terminal 4) but it really doesn't work for me.

if you are using the stir4200 driver then you are using an USB dongle that does not need the irattach to make it known to the IrDA subsystem. It will automatically make it known. For every IrDA dongle you attach you should see an irdaX with ifconfig.

The irattach (if I remember this correctly since this is long long time ago) is to take an IrDA device that is attached to a TTY and attach the IrDA ldisc to it to make it know to the IrDA subsystem. Not something that is needed for USB dongles with a proper driver. So the above should have never worked for you.

While the IrDA communication via /dev/ircommX is somehow possible, I do not remember how. What we used back in the days were IrDA sockets. I think if you look into Gnokii source you mind find an example on how to create an IrDA socket to talk to Nokia phone. Then again, this is so long time ago, I am not going to look at that since I am afraid that code is pretty ugly by todays standards.

Regards

Marcel
