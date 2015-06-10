From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 99671] New: glibc deadlock in __check_pf() presumed
 due to missing netlink response
Date: Tue, 09 Jun 2015 17:46:29 -0700
Message-ID: <1433897189.27504.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150609170434.1eeec625@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw2@infradead.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:33169 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbbFJAqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 20:46:33 -0400
Received: by qcnj1 with SMTP id j1so12189707qcn.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 17:46:32 -0700 (PDT)
In-Reply-To: <20150609170434.1eeec625@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-09 at 17:04 -0700, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Mon, 8 Jun 2015 21:20:23 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 99671] New: glibc deadlock in __check_pf() presumed due to missing netlink response
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=99671
> 
>             Bug ID: 99671
>            Summary: glibc deadlock in __check_pf() presumed due to missing
>                     netlink response
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.0
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: dwmw2@infradead.org
>         Regression: No
> 
> I keep seeing multithreaded processes deadlocked on glibc's __check_pf
> function, with the culprit stuck like this:
> 
> #0  0x0000003841302edd in recvmsg () at ../sysdeps/unix/syscall-template.S:81
> #1  0x000000384131f8ee in __check_pf (pid=-52599, fd=20) at
> ../sysdeps/unix/sysv/linux/check_pf.c:166
> #2  0x000000384131f8ee in __check_pf (seen_ipv4=seen_ipv4@entry=0x7f5b137fdc32,
> seen_ipv6=seen_ipv6@entry=0x7f5b137fdc33, in6ai=in6ai@entry=0x7f5b137fdc40,
> in6ailen=in6ailen@entry=0x7f5b137fdc48) at
> ../sysdeps/unix/sysv/linux/check_pf.c:324
> 
> I don't understand why the glibc code is waiting; even if netlink responses are
> dropped, it should get ENOBUFS and bail out.
> 
> This started happening to me, sporadically, when I updated my Fedora 22 beta
> installation to the 4.0 kernel. It seemed to go away when I reverted to 3.19,
> and came back again when I went back to 4.0. Filed in Red Hat bugzilla as
> https://bugzilla.redhat.com/show_bug.cgi?id=1209433 and reported upstream at 
> https://www.marc.info/?l=linux-netdev&m=142849461211078&w=3 and
> https://www.marc.info/?l=linux-netdev&m=142954024310299&w=3
> 
> Others seem to have seen it on earlier kernels though:
> https://github.com/nahi/httpclient/issues/232

Probably fixed by : 
http://patchwork.ozlabs.org/patch/473041/
