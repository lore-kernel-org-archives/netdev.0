From: Kees Cook <keescook@chromium.org>
Subject: Re: [RFC v3 11/22] seccomp,landlock: Handle Landlock hooks per
 process hierarchy
Date: Mon, 3 Oct 2016 16:52:32 -0700
Message-ID: <CAGXu5j+qowiyQuhifOBtupfPxp6XevdgF08BW4yzkVDTCha0xA@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-12-mic@digikod.net>
 <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com> <57D9D06C.2020007@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Andy Lutomirski <luto@amacapital.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux API <
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37986 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbcJCXwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 19:52:35 -0400
Received: by mail-wm0-f50.google.com with SMTP id p138so180098829wmb.1
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 16:52:34 -0700 (PDT)
In-Reply-To: <57D9D06C.2020007@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 3:34 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
>
> On 14/09/2016 20:43, Andy Lutomirski wrote:
>> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>> A Landlock program will be triggered according to its subtype/origin
>>> bitfield. The LANDLOCK_FLAG_ORIGIN_SECCOMP value will trigger the
>>> Landlock program when a seccomp filter will return RET_LANDLOCK.
>>> Moreover, it is possible to return a 16-bit cookie which will be
>>> readable by the Landlock programs in its context.
>>
>> Are you envisioning that the filters will return RET_LANDLOCK most of
>> the time or rarely?  If it's most of the time, then maybe this could
>> be simplified a bit by unconditionally calling the landlock filter and
>> letting the landlock filter access a struct seccomp_data if needed.
>
> Exposing seccomp_data in a Landlock context may be a good idea. The main
> implication is that Landlock programs may then be architecture specific
> (if dealing with data) as seccomp filters are. Another point is that it
> remove any direct binding between seccomp filters and Landlock programs.
> I will try this (more simple) approach.

Yeah, I would prefer that the seccomp code isn't doing list management
to identify the landlock hooks to trigger, etc. I think that's better
done on the LSM side. And since multiple seccomp filters could trigger
landlock, it may be best to just leave the low 16 bits unused
entirely. Then all state management is handled by the landlock eBPF
maps, not a value coming from seccomp that can get stomped on by new
filters, etc.

-Kees

--=20
Kees Cook
Nexus Security
