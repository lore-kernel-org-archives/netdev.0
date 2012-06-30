From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: AF_BUS socket address family
Date: Sat, 30 Jun 2012 13:52:40 +0100
Message-ID: <20120630135240.41dbaacf@pyramind.ukuu.org.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
	<20120629.153656.1141845894730637434.davem@davemloft.net>
	<20120629231236.GA28593@mail.collabora.co.uk>
	<20120629.161821.948325645333976311.davem@davemloft.net>
	<20120629234230.GA11480@kyllikki.org>
	<20120630001350.GS21968@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120630001350.GS21968@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Jun 2012 20:13:50 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> On Sat, Jun 30, 2012 at 12:42:30AM +0100, Vincent Sanders wrote:
> > The current users are suffering from the issues outlined in my
> > introductory mail all the time. These issues are caused by emulating an
> > IPC system over AF_UNIX in userspace.
> 
> Nothing in your introductory statements indicate how your requirements 
> can't be met through a hybrid socket + shared memory solution.  The IPC 
> facilities of the kernel are already quite rich, and sufficient for 
> building many kinds of complex systems.  What's so different about DBus' 
> requirements?

dbus wants to
- multicast
- pass file handles
- never lose an event
- be fast
- have a security model

The security model makes a shared memory hack impractical, the file
handle passing means at least some of it needs to be AF_UNIX. The event
loss handling/speed argue for putting it in kernel.

I'm not convinced AF_BUS entirely sorts this either. In particular the
failure case dbus currently has to handle for not losing events allows it
to identify who in a "group" has jammed the bus by not listening (eg by
locking up). This information appears to be lost in the AF_BUS case and
that's slightly catastrophic for error recovery.

Alan
