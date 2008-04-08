From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10423] New: af_rose sendmsg length check
Date: Tue, 8 Apr 2008 10:39:17 -0700
Message-ID: <20080408103917.d062a810.akpm@linux-foundation.org>
References: <bug-10423-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: thomas.pollet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34903 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751632AbYDHRjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 13:39:48 -0400
In-Reply-To: <bug-10423-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue,  8 Apr 2008 06:48:27 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10423
> 
>            Summary: af_rose sendmsg length check
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: thomas.pollet@gmail.com
> 
> 
> Hi,
> 
> the code from rose_sendmsg in sys/net/af_rose.c doesn't check the value of len. 
> suppose len is very big (0xfffffff8 for example) then "size" would overflow.
> 
>         size = len + AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + ROSE_MIN_LEN;
> 
> resulting in a buffer that's too small.
> 
> if ((skb = sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT, &err))
> == NULL)
>                 return err;
> 
> the buffer is filled here:
> 
> 1115         skb_put(skb, len);
> 1116 
> 1117         err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov,
> len);
> 
> 

It might be that it doesn't need to check.  We check that the total length
didn't overflow negative in sys_sendmsg()'s call to verify_iovec().

Of course, the addition which you identify might make a very large length
overflow 0x7fffffff, and subsequent code might handle that incorrectly.

