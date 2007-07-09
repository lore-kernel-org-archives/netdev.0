From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8726] New: MSG_TRUNC not regarded in
 unix_dgram_recvmsg()
Date: Mon, 9 Jul 2007 09:16:47 -0700
Message-ID: <20070709091647.9fce4cc0.akpm@linux-foundation.org>
References: <bug-8726-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, garkein@mailueberfall.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58881 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753913AbXGIQQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 12:16:58 -0400
In-Reply-To: <bug-8726-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  9 Jul 2007 04:01:58 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8726
> 
>            Summary: MSG_TRUNC not regarded in unix_dgram_recvmsg()
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.19
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: garkein@mailueberfall.de
> 
> 
> Problem Description:
> 
> In unix_dgram_recvmsg() in af_unix.c the flag MSG_TRUNC is not regarded as
> described in the recv(2) man page.
> 
> This did work in older kernels (I have a working 2.6.13, but am not sure if
> that is a plain kernel.org one, nor if it was the last working revision).
> I believe the bug was introduced when the variable "copied" was removed from
> the code.
> 
> IMHO, the line 1650:
> 
> err = size;
> 
> should read
> 
> err = (flags & MSG_TRUNC) ? skb->len : size;
> 
