From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Sat, 24 Apr 2004 15:18:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8DC30062.09C63CA2-ON87256E80.006EBEE0-86256E80.006F23A1@us.ibm.com>
References: <408AC7DC.8060204@myrealbox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <408AC7DC.8060204@myrealbox.com>
To: Andy Lutomirski <luto@myrealbox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>The 8001S was a typo -- mine is 8110S point-to-point with an e1000 on 
>Windows.  Strangely enough, I can't reproduce the problem today.  It 
>happened about 80% of the time yesterday, though.  I don't think I 
>changed anything.  Maybe my cable's bad.
>
>In any case, if I'm the only one with this problem, and no one knows 
>what the original purpose of the timer was, I'm ok with removing it 
>entirely.  I can work around this issue in userspace easily enough.

Your setup sounds similar to mine, though my test machine is running 
gentoo.  Anyway, I'll verify the speed settings it when I get home.

>I left it out b/c natsemi does it and it always annoys me ;)  Is there a 
>userspace tool for linkwatch?
>
>In any case, what's the preferred approach?  natsemi notifies, tulip 
>doesn't, and, IIRC, e1000 and tg3 don't.  If the consensus is to notify, 
>shouldn't it be done in netif_carrier_on and netif_carrier_off?

I just checked e1000, and it does log the link status in the dmesg (line 
1410 or so of e1000_main.c in the e1000_watchdog function).  It also does 
the netif_carrier_on/off there too.  If that is too much work in the 
interrupt handler, we can always do it via a timer.

Thanks,
Jon
