From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH iproute-3.8 0/6] ip netns bug fixes and enhancements
Date: Thu, 7 Feb 2013 10:17:06 -0800
Message-ID: <CAGK4HS8=V5EKRBs2jAqtBqrg-ghTiC0LoFaYo7cK6d-XOfvHwQ@mail.gmail.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
	<CAGK4HS_nZ-fk5628wgHke0491ESLaZumSj1ALqDamd4bzBYfBg@mail.gmail.com>
	<87obfw5wmj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:62396 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030219Ab3BGSRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 13:17:07 -0500
Received: by mail-qc0-f172.google.com with SMTP id b25so1108638qca.31
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 10:17:06 -0800 (PST)
In-Reply-To: <87obfw5wmj.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> On my system those defines are coming out of sys/mount.h and date back
> to 2.6.5 or so.  You should have them available on your system.

>
> What weird system are you on that doesn't export those?

The broken machine is not weird at all, just running a standard
version of Ubuntu (a little older though).
Ubuntu 10.04.1 LTS (lucid).
On this machine, I have the following version of libc6. Version:
2.11.1-0ubuntu7.10

The defines are not present in sys/mount.h but are in linux/fs.h. When
I include linux/fs.h, ipnetns.c compiles fine (but causes other
problems).
As Stephen said, it is probably the version of glibc that is causing this.

I verified this by trying to compile iproute2 on a newer version of
Ubuntu (Ubuntu 12.04.1 LTS, precise) which has glibc version
2.15-0ubuntu10.3. Everything compiles fine here.  The defines are
present in both linux/fs.h and x86_64-linux-gnu/sys/mount.h

I found the libc6 version by running 'aptitude show libc6'.  Let me
know if you need any other info.

>
> I don't have a clue on where to start at a practical level.  It wouldn't
> be hard to provide some #ifndef compat glue but I can't imagine why that
> would be needed.
>
> Eric

I didn't realize it was a libc versioning error. Sorry if this was noise.

Thanks,
Vijay
