From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15541] New: POLLIN bit is set when there is
 OOB data only
Date: Fri, 19 Mar 2010 15:55:41 -0700
Message-ID: <20100319155541.731eec28.akpm@linux-foundation.org>
References: <bug-15541-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Alexandra.Kossovsky@oktetlabs.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40759 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751932Ab0CSW4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 18:56:25 -0400
In-Reply-To: <bug-15541-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 15 Mar 2010 16:19:43 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15541
> 
>            Summary: POLLIN bit is set when there is OOB data only
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.28, 2.6.32, 2.6.33
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: Alexandra.Kossovsky@oktetlabs.ru
>                 CC: davem@davemloft.net
>         Regression: Yes
> 
> 
> Starting from 2.6.28, Linux kernel has incorrect behaviour when poll() is
> called on TCP socket with out-of-band byte received.
> 
> When TCP socket has OOB byte available (and no normal data), old Linux,
> Solaris, FreeBSD and other systems return POLLPRI bit without POLLRD.  Starting
> from 2.6.28, Linux returns POLLRD | POLLPRI | POLLRDNORM.
> 
> The broken commt is
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.28.y.git;a=commitdiff;h=c7004482e8dcb7c3c72666395cfa98a216a4fb70
> .
> Following 1-line patch fixes the problem:
> --- a/net/ipv4/tcp.c 2010-03-15 19:13:45.000000000 +0300
> +++ b/net/ipv4/tcp.c      2010-03-15 19:13:21.000000000 +0300
> @@ -428,7 +428,7 @@
>                 if (tp->urg_seq == tp->copied_seq &&
>                     !sock_flag(sk, SOCK_URGINLINE) &&
>                     tp->urg_data)
> -                       target--;
> +                       target++;
> 
>                 /* Potential race condition. If read of tp below will
>                  * escape above sk->sk_state, we can be illegally awaken
> 

Thanks.

(Please don't send patches via bugzilla - it causes lots of problems with
our usual patch management and review processes.

Please send this patch via email as per Documentation/SubmittingPatches. 
Suitable recipients may be found via scripts/get_maintainer.pl)


