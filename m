From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 17:37:48 +0400
Message-ID: <20080905133748.GA28656@2ka.mipt.ru>
References: <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com> <20080903220347.GA22395@2ka.mipt.ru> <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com> <20080905071754.GA25998@2ka.mipt.ru> <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com> <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com> <20080905113112.GA29926@2ka.mipt.ru> <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com> <20080905131618.GB12246@2ka.mipt.ru> <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:53184 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbYIENiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 09:38:15 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2008 at 03:29:25PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> So, it seems that there is something wrong in UDP here, because TCP
> works properly with same code.
> If size argument of sendfile() exceed 61440, sendfile() returns 61440
> and send no data to the device ...

That's a bug. Likely no one sends file content via udp, so it was not
detected...

> I will try to investigate it but for my app sendfile() is not
> conceivable. Only vmsplice could, but too slow.

Well, you can mmap empty file into the RAM, lock it there, DMA data from
the sensor to the mmapped area, add headers (just in the mapped area)
and then sendfile that file.. Single syscall, zero-copy, standard
interfaces :)

-- 
	Evgeniy Polyakov
