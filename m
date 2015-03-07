From: Willy Tarreau <w@1wt.eu>
Subject: Re: Network Receive Problems on NetGearRn104 Armarda370
Date: Sat, 7 Mar 2015 15:53:26 +0100
Message-ID: <20150307145326.GA5190@1wt.eu>
References: <20150307145154.7afcd4a4@michael> <20150307145630.0c56619e@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Langer <michael.brainbug.langer@t-online.de>,
	netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:64814 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271AbbCGOxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 09:53:30 -0500
Content-Disposition: inline
In-Reply-To: <20150307145630.0c56619e@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Mar 07, 2015 at 02:56:30PM +0100, Thomas Petazzoni wrote:
> Dear Michael Langer,
> 
> On Sat, 7 Mar 2015 14:51:54 +0100, Michael Langer wrote:
> 
> > I have a Network problem on my Armarda370 based NetGear RN104. I use the RN104 as TV and NFS Server. The TV Service gets its data from a network attached receiver via ip6 multicast stream. In case of nfs traffic or video streams > 20MBit into the box the kernel log is filled with error messages [1]. While for the NFS Service only performance id affected. For the TV Service I get visible artifarcts due to missing packets.
> > 
> > The RN104 is connected to a managed switch (ProCurve 1810G-24) configured without jumbo frame support (MTU=1518). I could not trigger these messages by running 'iperf -s' on the server and 'iperf -c <ip-addr>' on the client side (~930MBit)?! The RN104 is a relplacement unit for a Kirwood based NAS which is still working. The old NAS is working without packet loss, so I think that I can rule out the network receiver as a source of the missing packets. 
> > 
> > Things I have checked with no success:
> > - Ethernet hardware cable
> > - change port on switch
> > - chage port on RN104
> > - Kernel 3.17.1.rn104 from natisbad.org did not report errors but gave also artifarcts on TV-Stream
> > - Kernel Version 3.18,7, 3.19, 4.0-rc2
> > - ethtool playing with coalesce rx-usecs/frames and rx ring buffer count
> > - change nice level for TV-Service
> > 
> > At the moment I don't know how to proceed to solve the issue.
> 
> Thanks Michael for your detailed report. I'm adding Willy Tarreau in the
> loop, who has done a lot of work on Armada 370 networking. He may have
> some ideas of things to try to narrow down the problem.

For now I don't, as I have never experienced the rx overrun issues.
It makes me think that some Rx IRQs would not be delivered, or
something like this, which would be something completely new,
given that the only issues we've had with the controller were
on the Tx path.

Michael, have you tried with a lower MTU ? I have not played with
1518 on it yet, and if a problem was related to this, it could have
remained unnoticed. I've seen that you've played with several settings,
it might make sense to try to disable Rx csum in order to disable all
Rx optimizations, just in case. Since you increased your MTU, I'm
guessing that you're using VLANs, it might be possible that some
Rx optims are not properly done with VLANs. That's just pure guess,
of course.

> Do you know if you could produce a test case that would allow us to
> reproduce the problem?

Indeed, that would help a lot :-)

> I'm leaving the logs unchanged below so that Willy can have a look.

At least the log is quite detailed but all it tells me is that's a new
issue.

Thanks,
Willy
