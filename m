From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 20:33:20 +0100
Message-ID: <20070220193319.GA8800@outpost.ds9a.nl>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru> <20070220184242.GA30077@filer.fsl.cs.sunysb.edu> <20070220184859.GA1949@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josef Sipek <jsipek@fsl.cs.sunysb.edu>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:35273 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932974AbXBTTdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:33:24 -0500
Content-Disposition: inline
In-Reply-To: <20070220184859.GA1949@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 09:48:59PM +0300, Evgeniy Polyakov wrote:

> Likely first overhead related to cache population or gamma-ray radiation.
> If it happens only one (it does in my test), then everything is ok I
> think. Bert, how frequently you get that long recvfrom()?

I have plotted the average time for a single non-blocking UPDv4 recvfrom
call returning 100 bytes, based on the delay I insert between recvfrom
calls, as measured in cycles spent busywaiting.

In theory, this graph should show some slope, perhaps because of the higher
chance of context switches, cache evictions and purging of any branche-prediction
information the CPU might have kept. I'm no expert.

I measure a huge slope, however. Starting at 1usec for back-to-back system
calls, it rises to 2usec after interleaving calls with a count to 20
million.

4usec is hit after 110 million.

The graph, with semi-scientific error-bars is on
http://ds9a.nl/tmp/recvfrom-usec-vs-wait.png

The code to generate it is on:
http://ds9a.nl/tmp/recvtimings.c

I'm investigating this further for other system calls. It might be that my
measurements are off, but it appears even a slight delay between calls
incurs a large penalty.

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
