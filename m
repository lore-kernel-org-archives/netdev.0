From: Thomas Graf <tgraf@suug.ch>
Subject: Re: pkt_sched: Control group classifier
Date: Thu, 30 Oct 2008 15:24:17 +0100
Message-ID: <20081030142417.GL20815@postel.suug.ch>
References: <20081027.123056.22851224.davem@davemloft.net> <20081027.170524.124746723.davem@davemloft.net> <20081030105431.GI20815@postel.suug.ch> <166fe7950810300457h3b1c11c9m437aab08ddc8afa3@mail.gmail.com> <20081030131008.GK20815@postel.suug.ch> <166fe7950810300629v714c8860ke38255275b57a523@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55810 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228AbYJ3OX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 10:23:57 -0400
Content-Disposition: inline
In-Reply-To: <166fe7950810300629v714c8860ke38255275b57a523@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-10-30 06:29
> By assigning the parent to the cgroup before the new process is forked.
> 
> An excerpt from the patch I had sent out:
> 
> # write the current shell pid to the cgroup
> echo $$ > /dev/cgroup/file_transfer/tasks
> #start the new task (e.g. ftp)
> ftp foo.bar.com

This is actually new information, so far you have been proposing
echo $PID_OF_FILE_XFER_PROCESS > /dev/cgroup/file_transfer/tasks

I think this is a reasonable approach but not enough in some
situations. The cgroup documentation lists a web browser cgroup
as one of its example, how would you configure this exactly?
Creating wrapper scripts is possible but doesn't guarantee that
the user actually runs the wrapper rather than the actual browser
itself.

How does it work with kernel threads? F.e. knfsd.

I thought the point with cgroups was to allow the administrator to
classify processes based on exec notifications as found in the
documentation:

<quote>
With the ability to classify tasks differently for different resources
(by putting those resource subsystems in different hierarchies) then
the admin can easily set up a script which receives exec notifications
and depending on who is launching the browser he can

       # echo browser_pid > /mnt/<restype>/<userclass>/tasks
<endquote>

I think all arguments have been brought up. There are pros and cons
with either solution.

> Again in practice both these may be overkill since it should be
> relatively easy for a resource management daemon on the system to
> start new processes in a cgroup instead of attempting live migration.

I guess this is a matter of perspective. Personally I would find it
useful to be able to throw running processes into a cgroup and
limit their resource consumption.
