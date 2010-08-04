From: Jack Zhang <jack.zhang2011@gmail.com>
Subject: can TCP socket send buffer be over used?
Date: Tue, 3 Aug 2010 18:22:00 -0600
Message-ID: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36465 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757660Ab0HDAWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 20:22:24 -0400
Received: by vws3 with SMTP id 3so3593199vws.19
        for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 17:22:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I'm doing experiments with (modified*) software iSCSI over a link with
an emulated Round-Trip Time (RTT) of 100 ms by netem.

For example, when I set the send buffer size to 128 KB, i could get a
throughput up to 43 Mbps, which seems to be impossible as the (buffer
size) / RTT is only 10 Mbps.
And When I set the send buffer size to 512 KB, i can get a throughput
up to 60 Mbps, which also seems to be impossible as the (buffer size)
/ RTT is only 40 Mbps.

I understand that when the buffer size is set to 128 KB, I actually
got a buffer of 256 KB as the kernel doubles the buffer size. I also
understand that half the doubled buffer size is used for meta data
instead of the actual data to be transferred. So basically the
effective buffer sizes for the two examples  are just 128 KB and 512
KB respectively.

So I was confused because, theoretically, send buffers of 128 KB and
512 KB should achieve no more than 10 Mbps and 40 Mbps respectively
but I was able to get way much more than the theoretical limit. So
I was wondering is there any chance the send buffer can be "overused"?
or there is some other mechanism inside TCP is doing some
optimization?

* the modification is to disable "TCP_NODELAY" , enable
"use_clustering" for SCSI, and set different send buffer sizes for the
TCP socket buffer.

Any idea will be highly appreciated.

Thanks a lot!
