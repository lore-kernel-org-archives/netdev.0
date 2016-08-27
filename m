From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (netfilter match)
Date: Sat, 27 Aug 2016 16:19:05 +0200
Message-ID: <57C1A159.3040905@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="1AViPhua595H5srXjQ5OLiUBFcsaS6goS"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann
 <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S . Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4484-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160826230539.GA26683@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1AViPhua595H5srXjQ5OLiUBFcsaS6goS
Content-Type: multipart/mixed; boundary="kh3cLFMnt3QneMnCbueAoIcvaI7inpQLW"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 "David S . Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
 Sargun Dhillon <sargun@sargun.me>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
Message-ID: <57C1A159.3040905@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (netfilter match)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
In-Reply-To: <20160826230539.GA26683@ast-mbp.thefacebook.com>

--kh3cLFMnt3QneMnCbueAoIcvaI7inpQLW
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 27/08/2016 01:05, Alexei Starovoitov wrote:
> On Fri, Aug 26, 2016 at 05:10:40PM +0200, Micka=EBl Sala=FCn wrote:
>> To sum up, there is four related patchsets:
>> * "Landlock LSM: Unprivileged sandboxing" (this series)
>> * "Add Checmate, BPF-driven minor LSM" (Sargun Dhillon)
>> * "Networking cgroup controller" (Anoop Naravaram)
>> * "Add eBPF hooks for cgroups" (Daniel Mack)

>>> Anoop Naravaram's use case is to control the ports the applications
>>> under cgroup can bind and listen on.
>>> Such use case can be solved by such 'lsm cgroup controller' by
>>> attaching bpf program to security_socket_bind lsm hook and
>>> filtering sockaddr.
>>> Furthermore Sargun's use case is to allow further sockaddr rewrites
>>> from the bpf program which can be done as natural extension
>>> of such mechanism.
>>>
>>> If I understood Daniel's Anoop's Sargun's and yours use cases
>>> correctly the common piece of kernel infrastructure that can solve
>>> them all can start from Daniel's current set of patches that
>>> establish a mechanism of attaching bpf program to a cgroup.
>>> Then adding lsm hooks to it and later allowing argument rewrite
>>> (since they're already in the kernel and no ToCToU problems exist)

>> For the network-related series, I think it make more sense to simply
>> create a netfilter rule matching a cgroup and then add more features t=
o
>> netfilter (restrict port ranges and so on) thanks to eBPF programs.
>> Containers are (usually) in a dedicated network namespace, which open
>> the possibility to not only rely on cgroups (e.g. match UID,
>> netmask...). It would also be more flexible to be able to load a BPF
>> program in netfilter and update its maps on the fly to make dynamic
>> rules, like ipset does, but in a more generic way.

What do the netdev folks think about this design?


--kh3cLFMnt3QneMnCbueAoIcvaI7inpQLW--

--1AViPhua595H5srXjQ5OLiUBFcsaS6goS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwaFZAAoJECLe/t9zvWqVnOgIAJE9TzZwl16ivzLISKo6pHhM
op6kdDEYJERxX/xLBzeHWKYm2vFADhuWq8ijIAJmWFdriCSkJsX0x6YA4raUgEU7
cBTo26EqJ5zGPVIFWC4+PpXAxxQRS/s2lCqH4SRgtD2Shmpjb/end1IkEcuwFPiR
unrF3OuwOe/T9JT8xaTqrefjYfgV9f06nVbLGTdj8wHLZk7aV+dWAIcD0gVE9jIc
gtB7XVlHR0X1yKDIwKp0mgkAC/xgQtvCp5qNXtHPgZr3x7XEEhLa2IHE4WeFinCC
gLZF8ovbtHSr2Dr1A02p5EulOpvmvBZ5lqrk2F70RzRxrDbtX+luBJrnvpS5Ux8=
=inYj
-----END PGP SIGNATURE-----

--1AViPhua595H5srXjQ5OLiUBFcsaS6goS--
