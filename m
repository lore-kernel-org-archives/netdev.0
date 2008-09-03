From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 17:58:50 +0200
Message-ID: <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
References: <20080902194603.GA2825@2ka.mipt.ru>
	 <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
	 <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com>
	 <20080903.040626.198546183.davem@davemloft.net>
	 <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com>
	 <20080903132734.GA17541@2ka.mipt.ru>
	 <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
	 <20080903151340.GA7566@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:41824 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbYICP6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 11:58:53 -0400
Received: by py-out-1112.google.com with SMTP id p76so1541542pyb.10
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 08:58:51 -0700 (PDT)
In-Reply-To: <20080903151340.GA7566@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> What is the bus width and is there burst mode support?
> Not to point to the error in the speed calculation, just out of curiosity :)
> Always liked such tiny systems...

32 bits with burst support. This is a PPC 405 embedded into Xilinx V4
FPGA . (PLB bus)

>
> But why sendfile/splice does not work the same?
> It is (supposed to be) a zero-copy sending interface, which should be even
> more optimal, than your ring buffer approach, since uses just single
> syscall and no initialization of the data (well, there is page
> population and so on, but if file is in the ramdisk, it is effectively
> zero overhead). Can you run oprofile during sendfile() data transfer or
> describe behaviour (i.e. CPU usage and tcpdump).

I've never used oprofile before. I will get more logs and let you know.
Just a question: I don't want to use TCP for final application.
Is it expected that the kernel execute packet_sendmsg() when using
packet socket with splice()?  (because this function is doing a memcpy
from a buffer to a socket buffer).

Or is there a dedicated path for splicing? or maybe only in TCP read
(I can see that splice_read operator is redefined with
tcp_splice_read())?
And I've also faced some issues with the size of packet (it seems to
be limited to page size). It is really important for me to send large
packet. I've just decreased the packet size of pktgen script from 7200
to 4096 and the bitrate has fallen from 85Mbytes/s to 50Mbytes/s.
I understand that this is not a problem with TCP when sending a file,
we don't really care about accuracy of the packet size.
Do you know if there is way to adjust the size ?

And again, many thanks for your fast replies ;)
Johann Baudy

-- 
Johann Baudy
johaahn@gmail.com
