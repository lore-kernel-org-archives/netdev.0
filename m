From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16603] New: send of data > 4 GB fails on 64
 bit systems
Date: Mon, 27 Sep 2010 16:15:40 -0700
Message-ID: <20100927161540.776f748e.akpm@linux-foundation.org>
References: <bug-16603-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, bono@onlinehome.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44169 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756413Ab0I0XQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 19:16:39 -0400
In-Reply-To: <bug-16603-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 16 Aug 2010 10:01:09 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16603
> 
>            Summary: send of data > 4 GB fails on 64 bit systems
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: bono@onlinehome.de
>         Regression: No
> 
> 
> Sending of data using linux function send fails if size is too large. glibc
> function is:
> 
> ssize_t send(int sockfd, const void *buf, size_t len, int flags);
> 
> Type of len is size_t, argument is stored in a kernel structure msgheader which
> contains an iovec. This iovec contains a size_t (64bit) length field, but in
> the linux kernel in function tcp_sendmsg the following lines
> 
>        while (--iovlen >= 0) {
>                 int seglen = iov->iov_len;
>                 unsigned char __user *from = iov->iov_base;
> 
> 
> convert the len to int (32 bit).
> 
> Thus sending of 5 GB of data results in 1 GB sent (no problem), but sending of
> 4 GB results in 0 bytes sent.
> 
> Workaround in userspace is easy (e.g. instead of len use len < 0x8000000 ? len
> : 0x7fffffff) but the kernel should handle this correctly.
> 

whoops.

Yes, I think seglen should be size_t.  Do you know if making that
change fixes the bug?


