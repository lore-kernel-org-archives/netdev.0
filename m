From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the tip tree
Date: Wed, 15 Apr 2015 11:25:49 +1000
Message-ID: <20150415112549.173f49ab@canb.auug.org.au>
References: <20150407171858.2ad46594@canb.auug.org.au>
	<20150407084829.GA9577@gmail.com>
	<55239BAD.6040304@iogearbox.net>
	<20150407190527.1633a186@canb.auug.org.au>
	<5523BBE0.8030400@iogearbox.net>
	<55240342.9050900@plumgrid.com>
	<552435DD.5040802@iogearbox.net>
	<20150408150327.313be6a3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/GNefAMD9wSJcs.WOzYElYKP"; protocol="application/pgp-signature"
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	<netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150408150327.313be6a3@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/GNefAMD9wSJcs.WOzYElYKP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 8 Apr 2015 15:03:27 +1000 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> Hi all,
>=20
> On Tue, 07 Apr 2015 21:54:05 +0200 Daniel Borkmann <daniel@iogearbox.net>=
 wrote:
> >
> > On 04/07/2015 06:18 PM, Alexei Starovoitov wrote:
> > > On 4/7/15 4:13 AM, Daniel Borkmann wrote:
> > >> [ Cc'ing Dave, fyi ]
> > >>
> > >> On 04/07/2015 11:05 AM, Stephen Rothwell wrote:
> > >>> On Tue, 07 Apr 2015 10:56:13 +0200 Daniel Borkmann
> > >>> <daniel@iogearbox.net> wrote:
> > >>>> On 04/07/2015 10:48 AM, Ingo Molnar wrote:
> > >>>>> * Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > >>>>>
> > >>>>>> After merging the tip tree, today's linux-next build (powerpc
> > >>>>>> ppc64_defconfig) failed like this:
> > >>>>>>
> > >>>>>> kernel/events/core.c: In function 'perf_event_set_bpf_prog':
> > >>>>>> kernel/events/core.c:6732:15: error: 'struct bpf_prog_aux' has no
> > >>>>>> member named 'prog_type'
> > >>>>>>     if (prog->aux->prog_type !=3D BPF_PROG_TYPE_KPROBE) {
> > >>>>>>                  ^
> > >>>>>>
> > >>>>>> Caused by commit 2541517c32be ("tracing, perf: Implement BPF pro=
grams
> > >>>>>> attached to kprobes").
> > >>>>>
> > >>>>> Note, this must be some (rarely triggered) aspect of the ppc64
> > >>>>> defconfig that neither x86 randconfigs nor most other arch defcon=
figs
> > >>>>> expose?
> > >>>>
> > >>>> Note, this is a merge conflict with the work that went via net-next
> > >>>> tree,
> > >>>> i.e. 24701ecea76b ("ebpf: move read-only fields to bpf_prog and sh=
rink
> > >>>> bpf_prog_aux"). I believe that is why it didn't trigger on tip tre=
e.
> > >>>>
> > >>>> You should be able to resolve it in linux-next by changing the tes=
t to:
> > >>>>
> > >>>>     if (prog->prog_type !=3D BPF_PROG_TYPE_KPROBE) {
> > >>>
> > >>> Thanks Daniel, I will do that tomorrow.  Someone will have to remem=
ber
> > >>> to tell Linus.
> > >>
> > >> Yes, indeed, depending which tree is merged first.
> > >
> > > Daniel analysis is correct, but the fix for kernel/events/core.c
> > > should be:
> > > - if (prog->aux->prog_type !=3D BPF_PROG_TYPE_KPROBE) {
> > > + if (prog->type !=3D BPF_PROG_TYPE_KPROBE) {
> > > instead of 'prog->prog_type'
> >=20
> > Yes, absolutely, thanks!
>=20
> So I have applied that as a merge fix patch.

This patch is now needed when the net-next tree is merged with Linus'
tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/GNefAMD9wSJcs.WOzYElYKP
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVLb4hAAoJEMDTa8Ir7ZwVNIwP/RMbTqat1w8CyidQYHpIar8N
7vVcB5NXwRK14Sv7ftXU1lG5pJz9c6jP5mZJVSFR6RJCZuJdyab/1JPkMbPbi+m0
b18an+L5GwdJYhSKlei0rHqJLt70YrMoGHN30NMzJwk2EHaGKXd/+ldxMQ8uhKyA
ftd4jwrkKEDOA8Ufxc1STZknO1WBB6+j4XO1bwnt2g9qBohS/TKoCV0USRIkdFtF
wb4ljdZEf98Hnh+igoMk7igoQbxMxFgzLatq8yYGQNCLJBA8qnhNW4Y+hbqnKXSJ
+I6Rn9mDU3cVDE4IUvL8/Gbh1leG7CtWaIZRNAVlo8RMwYxhq1Taz/Itrq9V2RSJ
aJxf/4rhv3vImOsTQntLoWjyOQVZWLl4D0m472/X3/JNX9x1mLfFEQNn5CuMG8At
z6JDelRi8LTMxxSXxUGZLTChdc65hUJ6g5usXc9EHpqB4gzIn91TxuFprP+CIVkg
SJLRtIjcoOnbcp/oTG3NgGngUnHd5Y75wSPdLbTV0voGwa0xWKb9Ml/yf6lOs6GF
rzCmgmUX5ccr483YfOynqmbOnkAXOZY/47IY7wf2FsFZUY0jw2A1yvskZDcYYyRO
79Gnu8Drg5YQQNTyyW+COV+GPo1cbUTCwwqnWceJtz2tIe7OEPKuysPciQQ7wOUh
khAc6rIqom6pGHPUI+GW
=hG+b
-----END PGP SIGNATURE-----

--Sig_/GNefAMD9wSJcs.WOzYElYKP--
