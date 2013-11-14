From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 64981] New: pulseaudio over network desyncs
Date: Thu, 14 Nov 2013 13:40:30 -0800
Message-ID: <1384465230.28716.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131114125854.337ca105@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tjakobi@math.uni-bielefeld.de
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f176.google.com ([209.85.161.176]:45618 "EHLO
	mail-gg0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757255Ab3KNVkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:40:33 -0500
Received: by mail-gg0-f176.google.com with SMTP id u2so457260ggn.35
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 13:40:33 -0800 (PST)
In-Reply-To: <20131114125854.337ca105@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 12:58 -0800, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Thu, 14 Nov 2013 12:13:46 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 64981] New: pulseaudio over network desyncs
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=64981
> 
>             Bug ID: 64981
>            Summary: pulseaudio over network desyncs
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.10.18
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: liquid.acid@gmx.net
>         Regression: Yes
> 
> Hello,
> 
> I updated my dedicated audio server to 3.10.18 at the beginning of the week.
> Yesterday I noticed this issue:
> 
> When playing back a video/audio file with mpv (mplayer2 also works), where the
> audio is streamed from my local machine to the audio server via pulseaudio, the
> playback desyncs after 5~10 seconds.
> 
> The video playback goes into slow-mo, while the audio plays back fine from the
> DAC connected to the audio server. The maintainer of mpv explained that the
> application relies on the pulseaudio output module returning appropriate
> feedback about the samples played back.
> 
> Which in turns requires the audio server to reply properly. Going back to
> 3.10.17 solves the issue, so I bisected and got this commit:
> 
> tcp: TSQ can use a dynamic limit
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=0ae5f47eff2e543c3b94eec51c740f38a5071432
> 
> What is interesting, that I only get these 5~10 seconds of proper playback
> after boot of the system. If I don't reboot, all subsequent playback attempts
> result in an immediate desync.
> 
> I also double-checked that this is related to network. I setup an identical PA
> server here on my laptop (just with a different audio output device), updated
> the kernel to this specific commit and used another machine to play back some
> content. Results in the same issue, so I highly doubt this is related to audio
> components.
> 
> Greets,
> Tobias
> 

Should be fixed by : 

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=98e09386c0ef4dfd48af7ba60ff908f0d525cdee

Thanks !
