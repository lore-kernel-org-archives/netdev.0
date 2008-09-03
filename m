From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 19:13:40 +0400
Message-ID: <20080903151340.GA7566@2ka.mipt.ru>
References: <20080902194603.GA2825@2ka.mipt.ru> <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com> <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com> <20080903.040626.198546183.davem@davemloft.net> <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com> <20080903132734.GA17541@2ka.mipt.ru> <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:34591 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbYICPOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 11:14:12 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Wed, Sep 03, 2008 at 05:00:47PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> The driver and the hardware support DMA scater/gather and checksum offloading.
> 
> with pktgen and this below config, i reached 85MBytes/s ~ link
> saturation (I've reached the same bitrate with raw socket + TX RING
> ZeroCopy patch):

> I can't saturate the link from user space with either UDP, TCP or RAW
> socket due to copies and multiple system calls.
> 
> If the system is just doing one copy of the packet, it falls under
> 25Mbytes/s. This a simple memory bus which is only running at 100Mhz
> for data and instruction.

What is the bus width and is there burst mode support?
Not to point to the error in the speed calculation, just out of curiosity :)
Always liked such tiny systems...

> I think I've well understood why my bitrate is so bad from userspace
> using normal TCP,UDP or RAW socket.
> That's why I'm working on this zero copy solution (without copy
> between user and kernel or between kernel buffer and socket buffer;
> and with a minimum of system call).
> A kind of full zero-copy sending capability, HW accesses same buffers
> as the user.

But why sendfile/splice does not work the same?
It is (supposed to be) a zero-copy sending interface, which should be even
more optimal, than your ring buffer approach, since uses just single
syscall and no initialization of the data (well, there is page
population and so on, but if file is in the ramdisk, it is effectively
zero overhead). Can you run oprofile during sendfile() data transfer or
describe behaviour (i.e. CPU usage and tcpdump).

> In fact, I'm just suggesting the symmetric of packet mmap IO used for
> capture process with zero copy capability and I need to know what do
> you think about it.

Well, I'm not against this patch, but you pointed to the bug (or wrong
initialization in your code) of the sendfile, which has higher priority
imho :)

Actually if it is indeed a bug in splice code then (if fixed) it can
allow to have simpler zero-copy sulution for your problem.

-- 
	Evgeniy Polyakov
