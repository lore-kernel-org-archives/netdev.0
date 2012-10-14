From: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 21:48:43 +0200
Message-ID: <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	<1350242941.21172.17023.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:51009 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab2JNTsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 15:48:43 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so3194541iag.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 12:48:43 -0700 (PDT)
In-Reply-To: <1350242941.21172.17023.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> On Sun, 2012-10-14 at 17:38 +0200, Jan Hinnerk Stosch wrote:
>> Hi,
>> I detected a small regression since linux 3.6.0:
>> When I run "ntpq -p" to query the status of my ntp-daemon I receive a
>> timeout (localhost.localdomain: timed out, nothing received
>> ***Request timed out). Strace shows that connecting to the ipv6
>> loopback interface times out. If I explicitly use ipv4 (ntpq -4 -p)
>> everything works as intended. Downgrading to linux 3.5.6 solves that
>> issue.
>> I reported a bug both to my distribution
>> (https://bugs.archlinux.org/task/31775) and to the kernel bugtracker
>> (https://bugzilla.kernel.org/show_bug.cgi?id=48741) not knowing
>> exactly which component caused the regression, so I was told to ask
>> this here. At the kernel-report you find an strace and tcpdump output.
>> If you need any further information just tell me, but be patient as me
>> kernel knowledge tends to zero.
>> Thanks in advance, Jan Hinnerk
>> --
>
>
> What gives :
>
> cat /etc/ntp.conf
> lsof -p `pidof ntpd`
> ntpq -p ::1
>
>
>

ntp.conf is (without comments):
server fritz.box iburst
restrict default noquery nopeer nomodify
restrict 127.0.0.1
restrict ::1
driftfile /var/lib/ntp/ntp.drift
logfile /var/log/ntp.log

"lsof -p `pidof ntpd`" gives nothing

and "ntpq -p ::1" results in the same timeout error "::1: timed out,
nothing received
***Request timed out".
