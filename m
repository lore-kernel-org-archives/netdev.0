From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 18:02:32 +0100
Message-ID: <20070220170232.GA4730@outpost.ds9a.nl>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:33253 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030297AbXBTRCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 12:02:34 -0500
Content-Disposition: inline
In-Reply-To: <20070220164124.GA24930@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 07:41:25PM +0300, Evgeniy Polyakov wrote:

> It can be recvfrom only problem - syscall overhead on my p4 (core duo,
> debian testing) is bout 300 usec - to test I ran read('dev/zero', &data,
> 0) in a loop.

nsec I assume?

The usec numbers for read(fd, &c, 0) where fd is /dev/zero:
1.557667, 0.627667, 0.447333, 0.440000, 0.440000, 0.440000, 0.442333,
0.440000, 0.440000, 0.442333, 0.442333, 0.440000, 0.440000, 0.442333,
0.442667, 0.440000, 0.440000, 0.440000, 0.442333, 0.442667,

In usecs. Notice the same declining figure, but not as pronounced. With a
sleep(1) in between, we get:
1.692667, 1.800000, 0.782667, 1.282667, 0.665000, 0.980000, 0.925000,
0.887667, 0.662667, 0.862667, 1.077333, 1.442333, 0.660000, 1.890000,
0.672333, 0.795000, 0.647667, 0.692333, 0.750000, 0.865000,

This doesn't look all that unhealthy.

> Could you try to hack recvfrom() for your socket to always copy some
> empty buffer and check the results without waiting for packet?

That might be out of my reach before tomorrow :-)

> If you are not hurry I can test it myself tomorrow.

Thanks. My major problem is that in my measurements, I quite often see the
'worst case' 4usec result. It would not be a problem if it happens only
once, of course.

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
