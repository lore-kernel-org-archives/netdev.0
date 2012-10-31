From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH RFC net-next 2/4] bfin_mac:
 replace sys time stamps with raw ones instead.
Date: Wed, 31 Oct 2012 13:46:38 +0100
Message-ID: <20121031124638.GA14197@netboy.at.omicron.at>
References: <cover.1348851539.git.richardcochran@gmail.com>
 <84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
 <CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
 <20121030134112.GB2283@netboy.at.omicron.at>
 <CAA_GA1fW2zA2j66y7zfVe6+U-pb1=3mOyFFH+oDHimMFAXyH7Q@mail.gmail.com>
 <20121031083652.GC2327@netboy.at.omicron.at>
 <CAA_GA1cQojiaJat8gGmp3XYZVGOtKi2xoFS08hsYTGssdbWcRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Miroslav Lichvar <mlichvar@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	device-drivers-devel@blackfin.uclinux.org,
	Jacob Keller <jacob.e.keller@intel.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Patrick Ohly <patrick.ohly@intel.com>,
	David Miller <davem@davemloft.net>
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:39799 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab2JaMqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 08:46:52 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so531867eaa.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 05:46:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA_GA1cQojiaJat8gGmp3XYZVGOtKi2xoFS08hsYTGssdbWcRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 05:00:55PM +0800, Bob Liu wrote:
> On Wed, Oct 31, 2012 at 4:36 PM, Richard Cochran
> <richardcochran@gmail.com> wrote:
> > On Wed, Oct 31, 2012 at 02:29:23PM +0800, Bob Liu wrote:
> >
> >> Any guide how to use ptp4l to sync system time between two machines
> >> over ethernet?
> >
> > You can run ptp4l on two machines like this
> >
> >   ptp4l -i eth0 -q -v     # master
> >   ptp4l -i eth0 -q -v -s  # slave
> >
> 
> Thank you.
> But i'm still failed to sync system time.
> 
> On mater:
> -------------------------------
> root:/> date
> Wed Dec 20 01:31:02 UTC 2006
> root:/>
> root:/>   ptp4l -i eth0 -q -v
> ptp4l[33.520]: selected /dev/ptp0 as PTP clock
> ptp4l[33.520]: m
> ptp4l[33.520]: driver rejected most general HWTSTAMP filter
> ptp4l[33.520]: port 1: INITIALIZING to LISTENING on INITIALIZE
> ptp4l[33.524]: port 0: INITIALIZING to LISTENING on INITIALIZE
> ptp4l[39.524]: port 1: LISTENING to MASTER on ANNOUNCE_RECEIPT_TIMEOUT_EXPIRES
> .....
> 
> -----------------------------
> On slave:
> root:~> date
> Fri Jan  2 13:16:07 UTC 1970
> 
> root:~>   ptp4l -i eth0 -q -v -s
> ptp4l[39.624]: selected /dev/ptp0 as PTP clock
> ptp4l[39.628]: m
> ptp4l[39.628]: driver rejected most general HWTSTAMP filter
> ptp4l[39.628]: port 1: INITIALIZING to LISTENING on INITIALIZE
> ptp4l[39.632]: port 0: INITIALIZING to LISTENING on INITIALIZE
> ptp4l[39.664]: port 1: new foreign master 00e022.fffe.fe8529-1
> ptp4l[43.672]: selected best master clock 00e022.fffe.fe8529
> ptp4l[43.676]: port 1: LISTENING to UNCALIBRATED on RS_SLAVE
> ptp4l[44.688]: master offset -7968957480 s0 adj      +0 path delay       8120
> ptp4l[45.692]: master offset -7968953124 s0 adj      +0 path delay       9076
> ptp4l[46.696]: master offset -7968947340 s0 adj      +0 path delay       8860
> ptp4l[47.700]: master offset -7968941884 s1 adj      +0 path delay       8860
> ptp4l[48.704]: master offset       4564 s2 adj   +4564 path delay       8860
> ptp4l[48.704]: port 1: UNCALIBRATED to SLAVE on MASTER_CLOCK_SELECTED
> ptp4l[49.708]: master offset       5154 s2 adj   +6523 path delay       9086
> ptp4l[50.712]: master offset       3686 s2 adj   +6601 path delay       9322
> ptp4l[51.716]: master offset       2582 s2 adj   +6603 path delay       9322
> ptp4l[52.720]: master offset       1362 s2 adj   +6158 path delay       9438
> ptp4l[53.724]: master offset        658 s2 adj   +5862 path delay       9438
> ptp4l[54.728]: master offset        -85 s2 adj   +5317 path delay       9685
> ptp4l[55.732]: master offset       -113 s2 adj   +5263 path delay       9873
> ptp4l[56.748]: master offset         86 s2 adj   +5428 path delay       9930
> ptp4l[57.740]: master offset        166 s2 adj   +5534 path delay       9930
> ptp4l[58.744]: master offset       -247 s2 adj   +5171 path delay      10151
> ptp4l[59.748]: master offset        -39 s2 adj   +5305 path delay      10151
> ptp4l[60.752]: master offset        217 s2 adj   +5549 path delay      10151
> ptp4l[61.756]: master offset        256 s2 adj   +5653 path delay      10128
> .....

This looks perfect. Did you fixup the wrong time stamp shift?

> 
> root:~> date
> Fri Jan  2 13:16:45 UTC 1970
> root:~>
> 
> The system time in slave didn't change.

That is correct. Using RAW time stamping and PHC, the time in the PHC
changes, but not the system time. The system time may be slaved to
the PHC time using the phc2sys program.

Anyhow, it looks like this is working fine to me.

Thanks,
Richard
