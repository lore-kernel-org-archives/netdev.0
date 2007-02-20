From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Wed, 21 Feb 2007 11:46:23 +1300
Message-ID: <5640c7e00702201446sf0f2110wfcc97134e834fee1@mail.gmail.com>
References: <20070219231447.GA4400@outpost.ds9a.nl>
	 <p73d545drx6.fsf@bingen.suse.de>
	 <20070220162714.GA3245@outpost.ds9a.nl>
	 <20070220164124.GA24930@2ka.mipt.ru>
	 <20070220184242.GA30077@filer.fsl.cs.sunysb.edu>
	 <20070220184859.GA1949@2ka.mipt.ru>
	 <20070220193319.GA8800@outpost.ds9a.nl> <45DB6FD8.4050106@hp.com>
	 <20070220221719.GA16263@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "bert hubert" <bert.hubert@netherlabs.nl>,
	"Rick Jones" <rick.jones2@hp.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Josef Sipek" <jsipek@fsl.cs.sunysb.edu>,
	"Andi Kleen" <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:46527 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161029AbXBTWqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 17:46:25 -0500
Received: by wr-out-0506.google.com with SMTP id i31so2154693wra
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 14:46:24 -0800 (PST)
In-Reply-To: <20070220221719.GA16263@outpost.ds9a.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/21/07, bert hubert <bert.hubert@netherlabs.nl> wrote:
> I'm trying to figure out which processes have the most impact, I had already
> killed anything non-essential. But that still leaves 140 pids.
>
>         Bert
>
That sounds way too many pids. I run a script to shut down processes
when I do testing as it makes a HUGE difference to my timing of things
which can be quite critical.

Here's my list of 46 and that includes me sshing into a box and
checking for processes:
UnID        PID  PPID CMD
root         1     0 init [2]
root         2     1 [ksoftirqd/0]
root         3     1 [watchdog/0]
root         4     1 [events/0]
root         5     1 [khelper]
root         6     1 [kthread]
root        40     6 [kblockd/0]
root        41     6 [kacpid]
root       110     6 [cqueue/0]
root       111     6 [ata/0]
root       112     6 [ata_aux]
root       113     6 [kseriod]
root       135     6 [rt-test-0]
root       137     6 [rt-test-1]
root       139     6 [rt-test-2]
root       141     6 [rt-test-3]
root       143     6 [rt-test-4]
root       145     6 [rt-test-5]
root       147     6 [rt-test-6]
root       149     6 [rt-test-7]
root       151     6 [pdflush]
root       152     6 [pdflush]
root       153     6 [kswapd0]
root       154     6 [aio/0]
root       838     6 [kedac]
root       843     6 [kjournald]
root      1720     6 [ksuspend_usbd]
root      1721     6 [khubd]
root      1741     6 [kpsmoused]
root      2544     1 /sbin/syslogd
root      2554     1 /sbin/klogd -x
root      2851     1 /usr/sbin/inetd
root      2863     1 /usr/sbin/sshd
ntp       2954     1 /usr/sbin/ntpd -p /var/run/ntpd.pid -u 111:111 -g
root      3061     1 /bin/login --
root      3062     1 /sbin/getty 38400 tty2
root      3063     1 /sbin/getty 38400 tty3
root      3064     1 /sbin/getty 38400 tty4
root      3065     1 /sbin/getty 38400 tty5
root      3066     1 /sbin/getty 38400 tty6
ian       3083  3061 -bash
root     21518  2863 sshd: ian [priv]
ian      21520 21518 sshd: ian@pts/1
ian      21521 21520 -bash
ian      21747 21521 ps -ef

-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
