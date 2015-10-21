From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 09:32:35 -0700
Message-ID: <1445445155.22974.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org,
	Casper Dik <casper.dik@oracle.com>
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36725 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbbJUQch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 12:32:37 -0400
Received: by pacfv9 with SMTP id fv9so61657695pac.3
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 09:32:37 -0700 (PDT)
In-Reply-To: <5627A37B.4090208@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-21 at 15:38 +0100, Alan Burlison wrote:

> ----------
> Since at least Solaris 7 (1998), a thread which is sleeping
> on a file descriptor which is being closed by another thread,
> will be woken up.
> 
> To this end each thread keeps a list of file descriptors
> in use by the current active system call.

Ouch.

> 
> When a file descriptor is closed and this file descriptor
> is marked as being in use by other threads, the kernel
> will search all threads to see which have this file descriptor
> listed as in use. For each such thread, the kernel tells
> the thread that its active fds list is now stale and, if
> possible, makes the thread run.
> 

This is what I feared.
