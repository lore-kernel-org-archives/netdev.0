From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v3 11/22] seccomp,landlock: Handle Landlock hooks per
 process hierarchy
Date: Wed, 14 Sep 2016 11:43:54 -0700
Message-ID: <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-12-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
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
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux API <linu
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914072415.26021-12-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net=
> wrote:
> A Landlock program will be triggered according to its subtype/origin
> bitfield. The LANDLOCK_FLAG_ORIGIN_SECCOMP value will trigger the
> Landlock program when a seccomp filter will return RET_LANDLOCK.
> Moreover, it is possible to return a 16-bit cookie which will be
> readable by the Landlock programs in its context.

Are you envisioning that the filters will return RET_LANDLOCK most of
the time or rarely?  If it's most of the time, then maybe this could
be simplified a bit by unconditionally calling the landlock filter and
letting the landlock filter access a struct seccomp_data if needed.


>
> Only seccomp filters loaded from the same thread and before a Landlock
> program can trigger it through LANDLOCK_FLAG_ORIGIN_SECCOMP. Multiple
> Landlock programs can be triggered by one or more seccomp filters. This
> way, each RET_LANDLOCK (with specific cookie) will trigger all the
> allowed Landlock programs once.

This interface seems somewhat awkward.  Should we not have a way to
atomicaly install a whole pile of landlock filters and associated
seccomp filter all at once?

--Andy
