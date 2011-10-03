From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: Re: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt
 (v3)
Date: Mon, 3 Oct 2011 15:04:23 -0500
Message-ID: <20111003200423.GA5880@sergelap>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
 <1314993400-6910-4-git-send-email-serge@hallyn.com>
 <20110926191737.GA4562@albatros>
 <20110927132157.GB3111@sergelap>
 <20110927155659.GA22532@albatros>
 <20111001170047.GA2935@sergelap>
 <m1aa9i4zkx.fsf@fess.ebiederm.org>
 <m1zkhh3l83.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vasiliy Kulikov <segoon@openwall.com>,
	Serge Hallyn <serge@hallyn.com>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com,
	rdunlap@xenotime.net, kernel-hardening@lists.openwall.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40244 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756920Ab1JCUEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 16:04:46 -0400
Content-Disposition: inline
In-Reply-To: <m1zkhh3l83.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
> > "Serge E. Hallyn" <serge.hallyn@canonical.com> writes:
> >
> >> Quoting Vasiliy Kulikov (segoon@openwall.com):
> >>> On Tue, Sep 27, 2011 at 08:21 -0500, Serge E. Hallyn wrote:
> >>> > > First, the patches by design expose much kernel code to unprivileged
> >>> > > userspace processes.  This code doesn't expect malformed data (e.g. VFS,
> >>> > > specific filesystems, block layer, char drivers, sysadmin part of LSMs,
> >>> > > etc. etc.).  By relaxing permission rules you greatly increase attack
> >>> > > surface of the kernel from unprivileged users.  Are you (or somebody
> >>> > > else) planning to audit this code?
> >
> > Well in theory this codes does expose this code to unprivileged user
> > space in a way that increases the attack surface.    However right now
> > there are a lot of cases where because the kernel lacks a sufficient
> > mechanism people are just given root provileges so that can get things
> > done.  Network manager controlling the network stack as an unprivileged
> > user.  Random filesystems on usb sticks being mounted and unmounted
> > automatically when the usb sticks are inserted and removed.
> >
> > I completely agree that auditing and looking at the code is necessary I
> > think most of what will happen is that we will start directly supporting
> > how the kernel is actually used in the real world.  Which should
> > actually reduce our level of vulnerability, because we give up the
> > delusion that large classes of operations don't need careful
> > attention because only root can perform them.   Operations which the
> > user space authors turn around and write a suid binary for and
> > unprivileged user space performs those operations all day long.
> >
> >>> > I had wanted to (but didn't) propose a discussion at ksummit about how
> >>> > best to approach the filesystem code.  That's not even just for user
> >>> > namespaces - patches have been floated in the past to make mount an
> >>> > unprivileged operation depending on the FS and the user's permission
> >>> > over the device and target.
> >>> 
> >>> This is a dangerous operation by itself.
> >>
> >> Of course it is :)  And it's been a while since it has been brought up,
> >> but it *was* quite well thought through and throrougly discussed - see
> >> i.e. https://lkml.org/lkml/2008/1/8/131
> >>
> >> Oh, that's right.  In the end the reason it didn't go in had to do with
> >> the ability for an unprivileged user to prevent a privileged user from
> >> unmounting trees by leaving a busy mount in a hidden namespace.
> >>
> >> Eric, in the past we didn't know what to do about that, but I wonder
> >> if setns could be used in some clever way to solve it from userspace.
> >
> > Oh.  That is a good objection.  I had not realized that unprivileged
> > mounts had that problem.
> 
> I just re-read the discussion you are referring to and that wasn't

The one I linked was one discussion, but not the final one.

https://lkml.org/lkml/2008/10/6/72 is the one where the need for
revoke is brought up.

> it.  Fuse already has something like a revoke in it's umount -f
> implementation.

I'll have to (haven't yet) take a look at it.

-serge
