From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 14 Jun 2016 20:26:15 +0200
Message-ID: <20160614182615.GA2741@netboy>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613130059.GA20320@sisyphus.home.austad.us>
 <20160613193208.GA2441@netboy>
 <20160614093000.GB21689@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>
To: Henrik Austad <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33306 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbcFNS0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 14:26:21 -0400
Content-Disposition: inline
In-Reply-To: <20160614093000.GB21689@sisyphus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 11:30:00AM +0200, Henrik Austad wrote:
> So loop data from kernel -> userspace -> kernelspace and finally back to 
> userspace and the media application?

Huh?  I wonder where you got that idea.  Let me show an example of
what I mean.

	void listener()
	{
		int in = socket();
		int out = open("/dev/dsp");
		char buf[];

		while (1) {
			recv(in, buf, packetsize);
			write(out, buf + offset, datasize);
		}
	}

See?

> Yes, I know some audio apps "use networking", I can stream netradio, I can 
> use jack to connect devices using RTP and probably a whole lot of other 
> applications do similar things. However, AVB is more about using the 
> network as a virtual sound-card.

That is news to me.  I don't recall ever having seen AVB described
like that before.

> For the media application, it should not 
> have to care if the device it is using is a soudncard inside the box or a 
> set of AVB-capable speakers somewhere on the network.

So you would like a remote listener to appear in the system as a local
PCM audio sink?  And a remote talker would be like a local media URL?
Sounds unworkable to me, but even if you were to implement it, the
logic would surely belong in alsa-lib and not in the kernel.  Behind
the enulated device, the library would run a loop like the example,
above.

In any case, your patches don't implement that sort of thing at all,
do they?

Thanks,
Richard
