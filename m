From: Luke Hutchison <luke.hutch@gmail.com>
Subject: Networking hangs when too many parallel requests are made at once
Date: Tue, 9 Nov 2010 13:30:30 -0500
Message-ID: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:63001 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab0KISbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 13:31:12 -0500
Received: by ywc21 with SMTP id 21so4529497ywc.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 10:31:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since around Linux kernel 2.6.33 or so (but maybe as early as
2.6.31, not sure exactly what version), when restoring a crashed or
closed browser session of either Firefox or Chrome where lots of tabs
(say 10-40) open simultaneously, the networking stack is brought to
its knees -- most or all the tabs eventually time out without data, or
a few tabs might get some data and then display a partial web page.
This behavior occurs with either wifi or ethernet, and occurs when
booting from Fedora 14 on liveusb, so it does not appear to be a
configuration problem. I have a Toshiba Satellite Pro S300M-S2142
laptop with a Core 2 Duo P8600 CPU, Intel GM45 gfx, Intel 82567V
Gigabit Ethernet and Intel 5100 Wifi, running kernel
kernel-2.6.36-1.1.fc15.x86_64 on top of Fedora 14.

Sorry for the length of the following bug report, but it's quite hard
to describe the behavior succinctly.

Even after all tabs have timed out, it's impossible to get data by
opening a new tab -- nothing seems able to access the network
connection.  Networking is broken for other processes too -- for
example, commandline tools like ping don't work either.  The
connection still shows as up in NetworkManager, and sometimes after
5-10 minutes goes back to normal, but not always. "service network
restart" and/or "service NetworkManager restart" and/or "ifdown eth0 ;
ifup eth0" sometimes fixes the problem, but sometimes normal network
activity isn't restored for several minutes and may not act completely
normal again until a reboot.

DNS resolution is the most obviously affected by this.  If I reopen a
browser session and wait a few seconds for networking to hang, I can't
usually ping by domain name but I can (usually) ping by IP address.
However new browser tabs will hang at either name resolution *or*
waiting for data, so I'm not convinced this is just a problem with DNS
resolution.

Also sometimes (but not always) whatever weird state the network stack
on my laptop gets into, things are funky enough to screw up my home
router (two different Motorola Surfboard cable modems/routers), and
the cable modem sometimes has to be reset to get the connection back
to full speed again.  However it is not a router problem in general,
because:

(1) all these symptoms (except this last one where the router somehow
gets screwed up by the laptop's odd behavior) are present whether I
use a wired or wireless connection, and regardless of which network I
am connected to (home or anywhere else, or even when tethered to my
Nexus One), and in multiple countries I have been to in the last 6
months (Portugal, Germany, China).

also
(2) I used to be able to reopen a closed browser session with 40 tabs
and they would all load up just fine.  Then at some point after a
Rawhide update, this broke.

I can't put my finger on exactly when this broke, because I was
dealing with worse breakage for a while since Fedora kernel 2.6.31.5,
as I reported at the following link:

https://bugzilla.redhat.com/show_bug.cgi?id=555213#c1

Synopsis of the above "worse" bug report:
Basically in the very same situation (opening lots of browser tabs),
the machine would lock up hard and the fan would immediately blow at
100% speed.  It took a couple of months of Rawhide updates for this
bug to go away, but by the time this lockup bug was fixed around the
release of Fedora 13 at kernel version 2.6.33, the other network
issues I have described above became evident, and were triggered in
the same way -- thus I believe the two bugs may be related somehow.

My computer has been close to unusable for moderate browsing activity
for about 8 months of the year so far, across nearly two releases of
Fedora (F13 and F14 beta).  I filed the above bug report but it was
never commented on by RedHat engineers.  I figured the bug was
probably visible enough that somebody else should notice it and I just
kept hoping the next update would contain a fix, but not yet.  I
emailed one of the Red Hat kernel engineers and he suggested I ask
upstream.

Please advise me as to how to debug this problem further.  (I haven't
seen anything that looks suspicious in
dmesg output or /var/log/messages, to start with.)

Thank you,
Luke Hutchison
