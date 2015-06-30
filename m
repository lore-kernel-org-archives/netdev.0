From: Andy Lutomirski <luto@amacapital.net>
Subject: Wiring up direct socket calls on x86_32 Linux?
Date: Tue, 30 Jun 2015 14:14:38 -0700
Message-ID: <CALCETrUdqUm4eue2VaNPM7tkt1DSfAgo9fd-06rcys3F0q3rQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Larsson <alexl@redhat.com>,
	Cosimo Cecchi <cosimo@endlessm.com>,
	Dan Nicholson <nicholson@endlessm.com>,
	Network Development <netdev@vger.kernel.org>,
	libc-alpha <libc-alpha@sourceware.org>
To: X86 ML <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:34146 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbbF3VPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 17:15:00 -0400
Received: by lbnk3 with SMTP id k3so1389216lbn.1
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 14:14:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all-

sys_socketcall sucks.  If nothing else, it's impossible to filter with
seccomp.  Should we wire up the real socket calls so that user code
can (very slowly) start migrating?

I think the list is:
 - socket
 - bind
 - connect
 - listen
 - accept4
 - getsockname
 - getpeername
 - socketpair
 - send
 - sendto
 - sendmsg
 - recv
 - recvfrom
 - recvmsg
 - shutdown
 - setsockopt

I skipped accept, which is superseded by accept4.  sendmmsg and
recvmmsg are already wired up.

Thoughts?  The patch would be trivial.

Glibc people: If Linux wired up the syscalls, would glibc use them?

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
