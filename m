From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Wed, 04 Jun 2008 23:52:54 +0300
Message-ID: <484700A6.3020707@gmail.com>
References: <200806011515.14103.maximlevitsky@gmail.com>	 <4846B5F2.8090805@gmail.com> <396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adam Langley <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.188]:47559 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbYFDUw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 16:52:59 -0400
Received: by gv-out-0910.google.com with SMTP id e6so109187gvc.37
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2008 13:52:57 -0700 (PDT)
In-Reply-To: <396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adam Langley wrote:
> On Wed, Jun 4, 2008 at 8:34 AM, Maxim Levitsky <maximlevitsky@gmail.com> wrote:
>>> Is there a way to close all TCP sockets before/after suspend to ram?
> 
> As with most things, you should consider how this can be done from
> userspace first.
> 
> You can find the processes with TCP connections open by walking
> /proc/*/fd and readlink()ing the dents therein. Then you can match the
> inode numbers up with /proc/net/tcp to see if the given TCP connection
> is remote or not.
> 
> Now you want to kill those connections somehow. You could imagine
> doing it by injecting RST packets back into the kernel, but for that
> you would need to know the SEQ/ACK numbers for the connection. Since
> that's sensitive information, /proc/net/tcp doesn't carry it. It would
> have to be CAP_NET_ADMIN (read: root user) only and changing the
> formats of proc files based on the reading user is a no-no. So that
> would require another proc file; I've no idea how well that patch
> would be received.
This isn't a problem, since suspend/resume is done by root.
I was thinking about something like that, and thought that it is 
implemented, so I asked here.

So small question, as a root, I can get SEQ/ACK numbers of a connection?

I am thinking, that maybe such thing can be put in kernel (as optional 
feature)

I can even add a suspend timeout, so if suspend was longer that it, then 
reset the sockets, otherwise not.
setting the timeout to 0 (default) will disable the feature.


> 
> Another option would be to close the TCP connections from within the
> processes which have them. You could enumerate the processes, ptrace
> attach each one, wait() for SIGSTOP, get the current instr pointer and
> patch in some code to close the fds then unpatch the process and let
> it continue. That would be architecture specific, of couse.
> 
> When the process comes to reading/selecting the fds again it would get
> a 0 read and act like they had been closed.
> 
> I'll admit that neither solution is terribly wonderful.
> 
> 
> AGL
> 

Best regards,
	Maxim Levitsky
