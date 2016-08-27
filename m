From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 08/10] landlock: Handle file system comparisons
Date: Sat, 27 Aug 2016 15:45:56 +0200
Message-ID: <57C19994.6020709@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-9-git-send-email-mic@digikod.net>
 <CALCETrWzfgNvOHmKy5205A2qLJLYCZ+5RZOQR9vzQ1ubpo0vNA@mail.gmail.com>
 <57BEFC65.3090305@digikod.net>
 <CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="2iSGROxspoamNOQ1rhGIuuDhQCiVerlvJ"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Network Development <netd
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4482-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2iSGROxspoamNOQ1rhGIuuDhQCiVerlvJ
Content-Type: multipart/mixed; boundary="QLHO63FNKwwmNnBMHDjdfm0f9PiuFkwCi"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
 LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
 kernel-hardening <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>
Message-ID: <57C19994.6020709@digikod.net>
Subject: Re: [RFC v2 08/10] landlock: Handle file system comparisons
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-9-git-send-email-mic@digikod.net>
 <CALCETrWzfgNvOHmKy5205A2qLJLYCZ+5RZOQR9vzQ1ubpo0vNA@mail.gmail.com>
 <57BEFC65.3090305@digikod.net>
 <CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com>
In-Reply-To: <CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com>

--QLHO63FNKwwmNnBMHDjdfm0f9PiuFkwCi
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 26/08/2016 16:57, Andy Lutomirski wrote:
> On Thu, Aug 25, 2016 at 7:10 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>
>> On 25/08/2016 13:12, Andy Lutomirski wrote:
>>> On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digiko=
d.net> wrote:
>>>> Add eBPF functions to compare file system access with a Landlock fil=
e
>>>> system handle:
>>>> * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)=

>>>>   This function allows to compare the dentry, inode, device or mount=

>>>>   point of the currently accessed file, with a reference handle.
>>>> * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, fil=
e)
>>>>   This function allows an eBPF program to check if the current acces=
sed
>>>>   file is the same or in the hierarchy of a reference handle.
>>>>
>>>> The goal of file system handle is to abstract kernel objects such as=
 a
>>>> struct file or a struct inode. Userland can create this kind of hand=
le
>>>> thanks to the BPF_MAP_UPDATE_ELEM command. The element is a struct
>>>> landlock_handle containing the handle type (e.g.
>>>> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) and a file descriptor. This coul=
d
>>>> also be any descriptions able to match a struct file or a struct ino=
de
>>>> (e.g. path or glob string).
>>>
>>> This needs Eric's opinion.
>>>
>>> Also, where do all the struct file *'s get stashed?  Are they
>>> preserved in the arraymap?  What prevents reference cycles or absurdl=
y
>>> large numbers of struct files getting pinned?
>>
>> Yes, the struct file are kept in the arraymap and dropped when there i=
s
>> no more reference on them. Currently, the limitations are the maximum
>> number of open file descriptors referring to an arraymap and the maxim=
um
>> number of eBPF Landlock programs loaded in a process
>> (LANDLOCK_PROG_LIST_MAX_PAGES in kernel/seccomp.c).
>>
>> What kind of reference cycles have you in mind?
>=20
> Shoving evil things into the arraymaps, e.g. unix sockets with
> SCM_RIGHTS messages pending, eBPF program references, the arraymap fd
> itself, another arraymap fd, etc.

The arraymap of Landlock handles is strongly typed and can check the
kind of FD it get when creating/updating an entry, which is done for the
cgroup type. It may be wise to add another check for FS types as well,
which should be a one-liner. I'll do it for the next round.


>>
>> It probably needs another limit for kernel object references as well.
>> What is the best option here? Add another static limitation or use an
>> existing one?
>=20
> Dunno.  If RLIMIT_FILE could be made to work, that would be nice.

The RLIMIT_NOFILE is used for the eBPF map creation, but only the memory
limit is used to store the map entries (struct file pointers). I'll add
a new static limit for the number of FD-based arraymap entries because
it does not reflect the same semantic. The struct files are not usable
as FD, their only purpose is to be able to compare with another file.

 Micka=C3=ABl


--QLHO63FNKwwmNnBMHDjdfm0f9PiuFkwCi--

--2iSGROxspoamNOQ1rhGIuuDhQCiVerlvJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwZmUAAoJECLe/t9zvWqVXuAH/iXx9Un0tcY/eTXWW2nii5Vs
zocKUCVwcpddzY9Yk87Gm11fZyr37J0BvSaUN/SRWKg15ls8C0X0839OrYl+iMRE
OLGV4UOYFxvQ06uaZwSLi18r7bcpqvmGlHxJCposdXBEiC9sb3S6wv5aThq755mF
eUcHN2yKCvkOmtUtuGi8vV895UW3+BFs9nOXaeWpJJbadEdKrt/GNDx4WE1Qk50o
2OYRWfPy4Io4fLW2aD9Fxcuv05iCAj/l9oxNXgOS+rXTyxYymVkuvA+4A00aFK8G
O6H48b70AXQeOp19+cdUte9jhAXt4N+1PawwTsXH7orXD8IarpeCCWgEXtNHmto=
=RNV5
-----END PGP SIGNATURE-----

--2iSGROxspoamNOQ1rhGIuuDhQCiVerlvJ--
