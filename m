From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC net-next 1/1] ptp: add an ioctl to compare PHC time
 with system time
Date: Fri, 28 Sep 2012 10:26:38 +0200
Message-ID: <20120928082638.GB17636@netboy.at.omicron.at>
References: <cover.1348768886.git.richardcochran@gmail.com>
 <f0c20e2d1a303b0247b1e0e0def19f131de162ff.1348768886.git.richardcochran@gmail.com>
 <20120928075303.GB29438@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Stultz <john.stultz@linaro.org>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:41416 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab2I1I0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 04:26:50 -0400
Received: by wibhq12 with SMTP id hq12so7389237wib.1
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 01:26:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120928075303.GB29438@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 28, 2012 at 09:53:03AM +0200, Miroslav Lichvar wrote:
> On Thu, Sep 27, 2012 at 08:12:16PM +0200, Richard Cochran wrote:
> > This patch adds an ioctl for PTP Hardware Clock (PHC) devices that allows
> > user space to measure the time offset between the PHC and the system
> > clock. Rather than hard coding any kind of estimation algorithm into the
> > kernel, this patch takes the more flexible approach of just delivering
> > an array of raw clock readings. In that way, the user space clock servo
> > may be adapted to new and different hardware clocks.
> 
> Would it make sense to extend the ioctl to allow also comparing the
> PHC with another PHC or perhaps even a different system clock than
> CLOCK_REALTIME?
> 
> I'm thinking if someone wanted to synchronize one PHC to another, it
> should be better to work with phc1-phc2 offsets than combine phc1-sys
> and sys-phc2 offsets.

Yes, I did think of that, too. There are some reserved fields in the
ioctl. It would be possible to use one field as a clockid_t for the
second phc device. For the static CLOCK_XYZ clock ids we could have a
switch/case. Then we could read any two clocks in the same way as in
this patch.

I am guessing it would be possible to synchronize two PHC devices to
within a few microseconds this way. Probably that is not good enough
to implement a boundary clock, for example, so I have my doubts about
the utility of this. But in any case, it is possible, and I think that
feature can wait for now.

Thanks,
Richard
