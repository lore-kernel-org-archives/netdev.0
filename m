From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9132] New: fcntl GET_OWN reports 0 for sockets
 instead of PID
Date: Mon, 8 Oct 2007 10:11:29 -0700
Message-ID: <20071008101129.c5af10e1.akpm@linux-foundation.org>
References: <bug-9132-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: ff@ozog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51096 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751536AbXJHRME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 13:12:04 -0400
In-Reply-To: <bug-9132-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(please respond via emailed reply-to-all, not vie the bugzilla web interface)

On Mon,  8 Oct 2007 09:18:02 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9132
> 
>            Summary: fcntl GET_OWN reports 0 for sockets instead of PID
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: ff@ozog.com
> 
> 
> Most recent kernel where this bug did not occur: 2.6.22
> Distribution: Kubuntu
> Hardware Environment: VMWare workstation 6
> Software Environment: 
> Problem Description: calling fcntl with F_GETOWN on a socket gives allways zero
> instead of the PID of the socket. The fcntl code is right but the data is zero
> in the struct file element. It sounds like pid is not set when the socket is
> attached to the fd in sock_attach_fd() of net/socket.c.
> 
> I would add something like this:
> 
> file->f_owner.pid=find_get_pid(task->pid);
> file->f_owner.pid_type=PIDTYPE_PID;
> 
> in sock_attach_fd() of net/socket.c
> 
> Steps to reproduce:
> 
> s=socket(...);
> pid=fcntl(s, F_GETOWN);
> 

You state that the problem is present in 2.6.22 and also did not occur in
2.6.22.  I assume it has always been like this.
