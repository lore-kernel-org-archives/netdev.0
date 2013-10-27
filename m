From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Netem Delay Normal Distribution
Date: Sun, 27 Oct 2013 12:37:01 -0700
Message-ID: <20131027123701.7581550b@nehalam.linuxnetplumber.net>
References: <CAJx7G_xkrVkC7HGQZogivA_6-i2Gas6aJd-sOFNMEbmq8=cS0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anirup dutta <adutta2@uh.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:60599 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab3J0ThG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 15:37:06 -0400
Received: by mail-pa0-f42.google.com with SMTP id kp14so4402302pab.1
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 12:37:05 -0700 (PDT)
In-Reply-To: <CAJx7G_xkrVkC7HGQZogivA_6-i2Gas6aJd-sOFNMEbmq8=cS0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Oct 2013 21:31:03 -0500
anirup dutta <adutta2@uh.edu> wrote:

> Hello,
> 
> I try this on my device
> 
> sudo tc qdisc del dev eth0 root netem delay 100ms 20ms distribution normal
> 
> I use iperf for transmitting UDP packets and I modified its code to
> get per packet delay. When I plot the distribution of delays and
> analyze the delays they pass the normality tests.
> 
> The only problem that I am not able to understand is that the mean of
> those delays shift to 125ms. Its not only me. There was another study
> and it observed the same thing.
> 
> http://www.researchgate.net/publication/224256550_An_Empirical_Study_of_NetEm_Network_Emulation_Functionalities/file/d912f5058c9b1e409b.pdf
> 
> Figure 7
> 
> I found out that this command is valid
> 
> sudo tc qdisc del dev eth0 root netem delay 1ms 20ms distribution normal
> 
> So I have a feeling that mean gets shifted from the base delay to
> avoid negative delay values.
> 
> It would be great if someone can confirm how it is implemented?

The table distribution logic actually predates netem.
It came from NIST Net http://snad.ncsl.nist.gov/nistnet/
The code was direct copy from this public domain code.
