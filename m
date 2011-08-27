From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/10][pull request] Complete drivers/net/ move
Date: Sat, 27 Aug 2011 00:17:54 -0700
Message-ID: <CAL3LdT6qO-H0BB0WBZKtxt+C1V5Z1vvfk0E6bpQm4iHQW8_JfA@mail.gmail.com>
References: <1314247835-24586-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110824.220436.2170925789602864954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34643 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab1H0HR4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2011 03:17:56 -0400
Received: by fxh19 with SMTP id 19so3082035fxh.19
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2011 00:17:55 -0700 (PDT)
In-Reply-To: <20110824.220436.2170925789602864954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 22:04, David Miller <davem@davemloft.net> wrote=
:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 24 Aug 2011 21:50:25 -0700
>
>> The following are changes since commit 0856a304091b33a8e8f9f9c98e776=
f425af2b625:
>> =C2=A0 Scm: Remove unnecessary pid & credential references in Unix s=
ocket's send and receive path
>> and are available in the git repository at:
>> =C2=A0 master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-org=
anize master
>
> Still fails.
>
> Jeff, I'm not pulling any more, you're simply not testing this
> properly. =C2=A0You need to sit on this for a few days and start prop=
erly
> sanity checking what you're sending me. =C2=A0I should not get a brok=
en
> build when I just type make on an "allmodconfig" tree right after
> I pull from you.
>
> Repeat, that should never happen, ever.
>
> It's not rocket science what I do to sanity test this.
>
> Take a vanilla net-next tree, "make allmodconfig" and build it.
>
> Pull your tree, "make oldconfig" and try to build it again, it fails.
>
> Why aren't you testing that? =C2=A0Because that's the first thing the=
 rest
> of the world, especially everyone validating the -next tree, is going
> to do.
>

Dave I am sorry about the previous compile errors, I was not seeing
them when testing.  You were correct, I was not using the allmodconfig
during my testing.  Since then, I have found the solution to the
compile issue, and I have done several compile testing on the updated
patches (allmodconfig, allyesconfig, and several randconfig tests).
All looks fine.  This issue was that ATM, IRDA, and several others
where needed PPP along with Serial Line Header Compression to get
compiled.  While there were entries in drivers/net/Makefile for PPP
and SLIP, then would not call out the dependency directly.  So I just
needed to add the Makefile options available in
drivers/net/ppp/Makefile and drivers/net/slip/ in
drivers/net/Makefile.

I am doing 2 more sanity compile checks before re-submitting this
patchset (for that last time). :)

--=20
Cheers,
Jeff
