From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 12:19:06 +0300
Message-ID: <4C6E488A.4010100@fs.uni-ruse.bg>
References: <bug-16626-10286@https.bugzilla.kernel.org/>	 <20100819152143.8a57c465.akpm@linux-foundation.org>	 <4C6E0C99.2060407@fs.uni-ruse.bg>	 <20100819221142.b8f6a70a.akpm@linux-foundation.org>	 <4C6E1CBA.2060605@fs.uni-ruse.bg>	 <20100819232019.6f6074a8.akpm@linux-foundation.org>	 <4C6E202E.5030406@fs.uni-ruse.bg> <1282286070.2295.6.camel@edumazet-laptop> <4C6E3D58.5080303@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:35879 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751373Ab0HTJTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 05:19:09 -0400
In-Reply-To: <4C6E3D58.5080303@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 20.8.2010 =D0=B3. 11:31, Plamen Petrov =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
=2E..
> The next thing I will be trying is disabling
> GRO for the tg3 network card in my network
> startup scripts via my shiny new ethtool... ;)

So, for nearly half an hour now running 2.6.36-rc1-FS-00127-g763008c:

>
root@fs:~# w; uname -a
>  12:09:48 up 26 min,  1 user,  load average: 2.43, 1.93, 1.26
> USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
> root     pts/0    192.168.10.159   12:09    0.00s  0.02s  0.00s w
> Linux fs 2.6.36-rc1-FS-00127-g763008c #1 SMP Thu Aug 19 07:10:57 UTC =
2010 i686 Intel(R) Pentium(R) D CPU 3.00GHz GenuineIntel GNU/Linux

And that's with the usual load, which can be found here:
http://pvp.now.im/s/drraw.cgi?Mode=3Dview;Dashboard=3D1173713287.13177

The only addition I made was running
	ethtool -K ethX gro off
for each network card.

Which means that I have a Broadcom Tygon 3 (tg3) which doesn't
like "generic-receive-offload" at all!

With "generic-receive-offload" off, I will stay on
2.6.36-rc1-FS-00127-g763008c for as long as I can, just to
confirm that in fact the "default on" setting for gro in the
tg3 driver is the culprit for my troubles...

Where to next?
