From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] net: Clean up SCM_CREDENTIALS code
Date: Wed, 20 Mar 2013 23:54:05 -0700
Message-ID: <87k3p1z1iq.fsf@xmission.com>
References: <cover.1363815201.git.luto@amacapital.net>
	<cover.1363815201.git.luto@amacapital.net>
	<3d7ffb6d9b73971f1a526fc490ef84ef7a33eecc.1363815201.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57035 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932244Ab3CUGyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 02:54:12 -0400
In-Reply-To: <3d7ffb6d9b73971f1a526fc490ef84ef7a33eecc.1363815201.git.luto@amacapital.net>
	(Andy Lutomirski's message of "Wed, 20 Mar 2013 14:38:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> writes:

> I was curious whether the uids, gids, and pids passed around worked
> correctly in the presence of multiple namespaces.  I gave up trying
> to figure it out: there are two copies of the pid (one of which has
> type u32, which is odd), a struct cred * (!), and a separate kuid
> and kgid.  IOW, all of the relevant data is stored twice, and it's
> unclear which copy is used when.
>
> I also wondered what prevented a SO_CREDENTIALS message from being
> recieved when the credentials weren't filled out.  Answer: not very
> much (and there have been serious security bugs here in the past).
>
> So just rewrite the thing to store a pid_t relative to the init pid
> ns, a kuid, and a kgid, and to explicitly track whether the data is
> filled out.
>
> I haven't played with the secid code.  I have no idea whether it has
> similar problems.
>
> I haven't benchmarked this, but it should be a respectable speedup
> in the cases where the credentials are in use.

The basic principle of no longer passing the struct cred we can
certainly do.

I am less convinced about the struct pid, but arguably that is the
proper approach.

A patch that proclaims that you didn't understand what the code was
doing but you changed it anyway, suggests there are subtle bugs
in there that you overlooked.

Certainly killing NETLINK_CB(sbk).ssk is a bug.

I do think there is a lot of good stuff in here and if you break this up
into smaller patches simpler patches, and keep an eye on the speed of
sending things messages without credentials.  I am pretty certain you
can cook up something that is mergable.

Eric
