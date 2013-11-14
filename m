From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 64981] New: pulseaudio over network desyncs
Date: Thu, 14 Nov 2013 12:58:54 -0800
Message-ID: <20131114125854.337ca105@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:38911 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755049Ab3KNU65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 15:58:57 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so2634024pab.0
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 12:58:56 -0800 (PST)
Received: from samsung-9 ([170.173.0.21])
        by mx.google.com with ESMTPSA id wp8sm53590896pbc.26.2013.11.14.12.58.55
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 14 Nov 2013 12:58:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 14 Nov 2013 12:13:46 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 64981] New: pulseaudio over network desyncs


https://bugzilla.kernel.org/show_bug.cgi?id=64981

            Bug ID: 64981
           Summary: pulseaudio over network desyncs
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.18
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: liquid.acid@gmx.net
        Regression: Yes

Hello,

I updated my dedicated audio server to 3.10.18 at the beginning of the week.
Yesterday I noticed this issue:

When playing back a video/audio file with mpv (mplayer2 also works), where the
audio is streamed from my local machine to the audio server via pulseaudio, the
playback desyncs after 5~10 seconds.

The video playback goes into slow-mo, while the audio plays back fine from the
DAC connected to the audio server. The maintainer of mpv explained that the
application relies on the pulseaudio output module returning appropriate
feedback about the samples played back.

Which in turns requires the audio server to reply properly. Going back to
3.10.17 solves the issue, so I bisected and got this commit:

tcp: TSQ can use a dynamic limit
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=0ae5f47eff2e543c3b94eec51c740f38a5071432

What is interesting, that I only get these 5~10 seconds of proper playback
after boot of the system. If I don't reboot, all subsequent playback attempts
result in an immediate desync.

I also double-checked that this is related to network. I setup an identical PA
server here on my laptop (just with a different audio output device), updated
the kernel to this specific commit and used another machine to play back some
content. Results in the same issue, so I highly doubt this is related to audio
components.

Greets,
Tobias

-- 
You are receiving this mail because:
You are the assignee for the bug.
