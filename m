From: Antoine Martin <antoine@nagafix.co.uk>
Subject: AF_VSOCK status
Date: Tue, 5 Apr 2016 19:34:59 +0700
Message-ID: <5703B0F3.7050700@nagafix.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "stefanha@redhat.com >> Stefan Hajnoczi" <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nagafix.co.uk ([194.145.196.85]:57910 "EHLO
	mail.nagafix.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757696AbcDEMlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 08:41:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Forgive me if these questions are obvious, I am not a kernel developer.
>From what I am reading here:
http://lists.linuxfoundation.org/pipermail/virtualization/2015-December/030935.html
The code has been removed from mainline, is it queued for 4.6? If not,
when are you planning on re-submitting it?

We now have a vsock transport merged into xpra, which works very well
with the kernel and qemu versions found here:
http://qemu-project.org/Features/VirtioVsock
Congratulations on making this easy to use!
Is the upcoming revised interface likely to cause incompatibilities with
existing binaries?

It seems impossible for the host to connect to a guest: the guest has to
initiate the connection. Is this a feature / known limitation or am I
missing something? For some of our use cases, it would be more practical
to connect in the other direction.

In terms of raw performance, I am getting about 10Gbps on an Intel
Skylake i7 (the data stream arrives from the OS socket recv syscall
split into 256KB chunks), that's good but not much faster than
virtio-net and since the packets are avoiding all sorts of OS layer
overheads I was hoping to get a little bit closer to the ~200Gbps memory
bandwidth that this CPU+RAM are capable of. Am I dreaming or just doing
it wrong?

In terms of bandwidth requirements, we're nowhere near that level per
guest - but since there are lot of guests per host, I use this as a
rough guesstimate of the efficiency and suitability of the transport.

How hard would it be to introduce a virtio mmap-like transport of some
sort so that the guest and host could share some memory region?
I assume this would give us the best possible performance when
transferring large amounts of data? (we already have a local mmap
transport we could adapt)

Thanks
Antoine
