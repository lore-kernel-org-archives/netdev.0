From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: netlink and user namespaces
Date: Fri, 29 May 2015 11:14:11 -0500
Message-ID: <87vbfb4azw.fsf@x220.int.ebiederm.org>
References: <1432901907.7545.30.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Containers <containers@lists.linux-foundation.org>
To: Alexander Larsson <alexl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59395 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbE2QTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:19:11 -0400
Cc: <netdev@vger.kernel.org>
In-Reply-To: <1432901907.7545.30.camel@redhat.com> (Alexander Larsson's
	message of "Fri, 29 May 2015 14:18:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Larsson <alexl@redhat.com> writes:

> Now that I'm using a non-privileged user namespace for my desktop
> sandboxing system all kind of network status things are breaking. The
> reason for this is that they use netlink to enumerated interfaces, and
> to verify that the replies are from the kernel (apparently anyone can
> send anyone netlink messages) this code is verifying that the
> SCM_CREDENTIAL sender of the netlink messages is uid 0.
>
> For instance: 
> http://git.0pointer.net/avahi.git/commit/avahi-core/netlink.c?id=37b2be93e63ceff95698f24cd91cb11774eb621c
> and:
> https://git.gnome.org/browse/glib/tree/gio/gnetworkmonitornetlink.c#n340
>
> This obviously breaks when uid is not mapped (as it can't be in an
> unprivileged user namespace), as uid will be overflowuid.
>
> Is there any other way to check that a netlink message is from the
> kernel?

*scratches my head*  Those are weird pieces of code.

The answer is the way you do this with any other socket.

Call recvfrom or recvmsg.
Looking at the senders address.
If in the senders address nl_pid == 0 then the message is from
the kernel.  Otherwise the message is from userspace.

Looking anywhere else at anything else is bogus.

And a note.  nl_pid is short for netlink port id.  It is not a process id.

Eric
