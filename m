From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 18:19:11 +0400
Message-ID: <20080905141911.GA16586@2ka.mipt.ru>
References: <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com> <20080905071754.GA25998@2ka.mipt.ru> <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com> <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com> <20080905113112.GA29926@2ka.mipt.ru> <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com> <20080905131618.GB12246@2ka.mipt.ru> <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com> <20080905133748.GA28656@2ka.mipt.ru> <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:53237 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218AbYIEOTk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 10:19:40 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Fri, Sep 05, 2008 at 03:55:14PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> > That's a bug. Likely no one sends file content via udp, so it was not
> > detected...
> 
> Ok, I'll will run a FTRACE of this issue on monday;

No need to run FTRACE, code shuld be audited and probably some debug
prints added to determine, why sendfile() decides to exit early wiht
UDP. I will try to do it if time permits this weekend, although I'm
quite surprised sendfile() does not work with UDP...

> > Well, you can mmap empty file into the RAM, lock it there, DMA data from
> > the sensor to the mmapped area, add headers (just in the mapped area)
> > and then sendfile that file.. Single syscall, zero-copy, standard
> > interfaces :)
> 
> OK but it seems that there is no way to control packet format.
> (beginning of packet and size of packet).
> Each packet must start with a specific header (on my app). This is a
> kind of streaming.

You can always provide a global offset where to put next packet.
You can ajust it to put header before each data frame, and then DMA
frame content according to that offset.

Transmitting packet socket is needed for those, who wants to implement
own low-level protocol unsupported by the kernel, so to transfer data
over UDP or TCP over IP with the highests speeds, one should use
existing methods. This does not of course mean, that anyone _has_ to do
it, it is always very fun to find new ways like your patch.

-- 
	Evgeniy Polyakov
