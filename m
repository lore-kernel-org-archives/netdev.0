From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Regarding bottlenecks for high speed packet generation
Date: Sat, 27 Oct 2012 09:25:54 +0530
Message-ID: <CADAe=+JHvZotYLY0=8MK1+sbL8K+F21-A5nSOQuNYrkTaBMfqg@mail.gmail.com>
References: <CADAe=++9KHUx3qX+2==+q0Fq44CJ9tjYcO=HdLYOF3FVuM5Vtg@mail.gmail.com>
 <CAD6jFUScXX0x7yU2f-Cq4B6RZdnQx4dkbADHBL9aYhzQmeKGgA@mail.gmail.com>
 <CADAe=+L2hXpYwH-XyNS2HyHQrMQRCmV_v-bs0Qp+sR-mVkzV4A@mail.gmail.com>
 <20121025.231814.962022530355865788.davem@davemloft.net> <CADAe=+LSeTWTnDk3o46EiLMQqJ6q93yVP_D3J2Ufcfy-_cv6RA@mail.gmail.com>
 <1351268139.2584.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: danborkmann@iogearbox.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54975 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964866Ab2J0D4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 23:56:25 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so3200764obb.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 20:56:25 -0700 (PDT)
In-Reply-To: <1351268139.2584.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> The network core needs to account and limit how much memory is allocated
> to socket buffers.  Completed TX buffers should therefore be freed
> promptly, to avoid blocking the sending socket unnecessarily.  It
> doesn't strictly matter whether this is triggered by an IRQ from the NIC
> or by a timer, but it certainly must not be triggered by the next TX
> initiation as this may result in a kind of deadlock.

My understanding is when an SKB is created we create it from the
amount of socket send buffer and sent to
device driver which sends to the hardware for transmission. Once the
NIC is done transmitting the packet an
interrupt allows the SKB to be freed returning the same amount of
memory back to socket send buffer.
I can see that even if I allocate 150MB for socket TX buffer size
after generating around 14k packets
the memory is exhausted. So ideally it means NIC is not able to
transmit the data at the rate it is being
received data from user.

As @dan mentioned earlier I have tried pktgen generating a 1500byte
packets. I can reach not more than
72MB/s but the CPU utilization has peaked 80% on the core on which
pktgen is binded with.

Regards,
Ajith
