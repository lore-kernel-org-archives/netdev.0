From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned to
	classes
Date: Thu, 3 Jun 2010 11:30:20 +0200
Message-ID: <AANLkTinTSQ6Ncz3FqgFHasJc2ZKfm2vaweJHUam9b-gi@mail.gmail.com>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com> <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org> <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org> <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org> <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	<m1y6exux6x.fsf@fess.ebiederm.org> <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	<m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.211.179]:56129 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933552Ab0FCJag convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 05:30:36 -0400
Received: by ywh9 with SMTP id 9so6145802ywh.17
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 02:30:35 -0700 (PDT)
In-Reply-To: <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 3, 2010 at 02:53, Eric W. Biederman <ebiederm@xmission.com>=
 wrote:
>
> In the last painful restructuring of sysfs we created started
> creating class directories under normal devices so we could place
> devices such as network devices directly under their the hardware
> that implements them instead of in their class directories like
> /sys/class/net/. =C2=A0This creation of class directories avoids the
> need to worry about namespace clonflicts if something is renamed.
>
> A special exception was made for devices that were still placed
> directly in their class directory. =C2=A0Looking at how this interact=
s
> with the wireless network devices it appears this special exception
> is either completely unneeded or at least needs to be restricted to
> a parent device with the same class as the child device. =C2=A0Certai=
nly
> in the case of unrelated classes we very much have the possibility
> of namespace classes and we should be creating the subdirectory.

The class-glue-directories are only created between a bus-parent and
and a class device. Class devices usually don't have other class
devices as parents, that's why it wasn't done that way.

If people use class devices from other classes as parents, they should
definitely convert the class that acts as a parent to a bus, to fit
into the usual model. All that was really never meant to be used that
way. The current behavior, to not to create the glue-directory is at
least the intended one from the driver core's perspective.

What kind of classes do this, where this change would help or would be =
needed?

I don't mind trying if that change will work for people, I can't tell
if there are any other users doing things like this which could break
with such a change. Stuff like udev will be fine with directories
inserted, but there are many things out there, that just access their
parents attributes with ../../foo, which might no longer work when we
insert directories.

Thanks,
Kay
