From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 08/10] landlock: Handle file system comparisons
Date: Thu, 25 Aug 2016 16:10:45 +0200
Message-ID: <57BEFC65.3090305@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-9-git-send-email-mic@digikod.net>
 <CALCETrWzfgNvOHmKy5205A2qLJLYCZ+5RZOQR9vzQ1ubpo0vNA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="buVtJtlbDg4l64d2Sg4eleSihPhdlHkLj"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
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
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <kernel-hardening-return-4467-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrWzfgNvOHmKy5205A2qLJLYCZ+5RZOQR9vzQ1ubpo0vNA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--buVtJtlbDg4l64d2Sg4eleSihPhdlHkLj
Content-Type: multipart/mixed; boundary="La8X7jJhO3jlBFav7063jHIBuifDCKJ0E"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>,
 "Eric W. Biederman" <ebiederm@xmission.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
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
Message-ID: <57BEFC65.3090305@digikod.net>
Subject: Re: [RFC v2 08/10] landlock: Handle file system comparisons
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-9-git-send-email-mic@digikod.net>
 <CALCETrWzfgNvOHmKy5205A2qLJLYCZ+5RZOQR9vzQ1ubpo0vNA@mail.gmail.com>
In-Reply-To: <CALCETrWzfgNvOHmKy5205A2qLJLYCZ+5RZOQR9vzQ1ubpo0vNA@mail.gmail.com>

--La8X7jJhO3jlBFav7063jHIBuifDCKJ0E
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 25/08/2016 13:12, Andy Lutomirski wrote:
> On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> Add eBPF functions to compare file system access with a Landlock file
>> system handle:
>> * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
>>   This function allows to compare the dentry, inode, device or mount
>>   point of the currently accessed file, with a reference handle.
>> * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)=

>>   This function allows an eBPF program to check if the current accesse=
d
>>   file is the same or in the hierarchy of a reference handle.
>>
>> The goal of file system handle is to abstract kernel objects such as a=

>> struct file or a struct inode. Userland can create this kind of handle=

>> thanks to the BPF_MAP_UPDATE_ELEM command. The element is a struct
>> landlock_handle containing the handle type (e.g.
>> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) and a file descriptor. This could
>> also be any descriptions able to match a struct file or a struct inode=

>> (e.g. path or glob string).
>=20
> This needs Eric's opinion.
>=20
> Also, where do all the struct file *'s get stashed?  Are they
> preserved in the arraymap?  What prevents reference cycles or absurdly
> large numbers of struct files getting pinned?

Yes, the struct file are kept in the arraymap and dropped when there is
no more reference on them. Currently, the limitations are the maximum
number of open file descriptors referring to an arraymap and the maximum
number of eBPF Landlock programs loaded in a process
(LANDLOCK_PROG_LIST_MAX_PAGES in kernel/seccomp.c).

What kind of reference cycles have you in mind?

It probably needs another limit for kernel object references as well.
What is the best option here? Add another static limitation or use an
existing one?

 Micka=C3=ABl


--La8X7jJhO3jlBFav7063jHIBuifDCKJ0E--

--buVtJtlbDg4l64d2Sg4eleSihPhdlHkLj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXvvxlAAoJECLe/t9zvWqVsPUH/1b4l5MMTaIx/g9AZZNDBTS4
nyL1T4v9TLpdhPloMh9rhMPqg57wv46NrmShPi7paPjQPGpzjLLbfB7vJDfI/5iP
FyN9fu8hVU4KSSD+FFTI6FHcn2yRgPi/qnJoeRV5JTmmrMKJztbZvVqpCpSDoY5X
UKpdVt6bpj6a0Mc+3tipIWDOLuKlmeO7VMoEMbDCIvFcJIJbo+MayeZ14uB40Ztx
V9H/ZI2Ba9dhnLkGr7P+GQPHyX+NHtG8PmUNrkrCW6OykFnuq2y+j6D9LA/OOU+r
kKpdqKPKQp4qmxcaVRDo6UMUHBdbjmHtlmf0ylyTycZmsBd2tQqT72pUPbcwy6A=
=CwX+
-----END PGP SIGNATURE-----

--buVtJtlbDg4l64d2Sg4eleSihPhdlHkLj--
