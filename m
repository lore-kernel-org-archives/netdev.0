From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 07/12] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 27 Feb 2012 10:22:09 -0600
Message-ID: <CABqD9hZcBiG579hUuxkvmUE122vVee_u9Ta7Hwrp4h-Sb8Lbcg@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-7-git-send-email-wad@chromium.org>
	<CAGXu5jLVwYev3EmLOKuEdyaqieGzWgVpFcgodnUbUkbMbiJVqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jLVwYev3EmLOKuEdyaqieGzWgVpFcgodnUbUkbMbiJVqQ@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 25, 2012 at 2:20 PM, Kees Cook <keescook@chromium.org> wrot=
e:
> On Fri, Feb 24, 2012 at 7:21 PM, Will Drewry <wad@chromium.org> wrote=
:
>> This change adds the SECCOMP_RET_ERRNO as a valid return value from =
a
>> seccomp filter. =A0Additionally, it makes the first use of the lower
>> 16-bits for storing a filter-supplied errno. =A016-bits is more than
>> enough for the errno-base.h calls.
>>
>> Returning errors instead of immediately terminating processes that
>> violate seccomp policy allow for broader use of this functionality
>> for kernel attack surface reduction. =A0For example, a linux contain=
er
>> could maintain a whitelist of pre-existing system calls but drop
>> all new ones with errnos. =A0This would keep a logically static atta=
ck
>> surface while providing errnos that may allow for graceful failure
>> without the downside of do_exit() on a bad call.
>>
>> v11: - check for NULL filter (keescook@chromium.org)
>> v10: - change loaders to fn
>> =A0v9: - n/a
>> =A0v8: - update Kconfig to note new need for syscall_set_return_valu=
e.
>> =A0 =A0 - reordered such that TRAP behavior follows on later.
>> =A0 =A0 - made the for loop a little less indent-y
>> =A0v7: - introduced
>>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>
> Reviewed-by: Kees Cook <keescook@chromium.org>

Thanks!

>> + =A0 =A0 =A0 /* Ensure unexpected behavior doesn't result in failin=
g open. */
>> + =A0 =A0 =A0 if (unlikely(current->seccomp.filter =3D=3D NULL))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D SECCOMP_RET_KILL;
>
> Any reason to not just immediately return in this case?

Not that I can think of. I can just have it bail here.
