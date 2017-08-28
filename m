From: James Morris <jmorris@namei.org>
Subject: Re: Re: [PATCH net-next v7 02/10] bpf: Add eBPF
 program subtype and is_valid_subtype() verifier
Date: Mon, 28 Aug 2017 13:48:41 +1000 (AEST)
Message-ID: <alpine.LRH.2.20.1708281347090.8842@namei.org>
References: <20170821000933.13024-1-mic@digikod.net> <20170821000933.13024-3-mic@digikod.net> <20170823024452.zvizovwfd7xjucsx@ast-mbp> <607ceb21-5aa5-678b-4438-0d8dcb69fc3c@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="1665246916-1251487109-1503892121=:8842"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
To: =?ISO-8859-15?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-9573-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <607ceb21-5aa5-678b-4438-0d8dcb69fc3c@digikod.net>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1665246916-1251487109-1503892121=:8842
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT

On Wed, 23 Aug 2017, Mickaël Salaün wrote:

> >> +	struct {
> >> +		__u32		abi; /* minimal ABI version, cf. user doc */
> > 
> > the concept of abi (version) sounds a bit weird to me.
> > Why bother with it at all?
> > Once the first set of patches lands the kernel as whole will have landlock feature
> > with a set of helpers, actions, event types.
> > Some future patches will extend the landlock feature step by step.
> > This abi concept assumes that anyone who adds new helper would need
> > to keep incrementing this 'abi'. What value does it give to user or to kernel?
> > The users will already know that landlock is present in kernel 4.14 or whatever
> > and the kernel 4.18 has more landlock features. Why bother with extra abi number?
> 
> That's right for helpers and context fields, but we can't check the use
> of one field's content. The status field is intended to be a bitfield
> extendable in the future. For example, one use case is to set a flag to
> inform the eBPF program that it was already called with the same context
> and can skip most of its check (if not related to maps). Same goes for
> the FS action bitfield, one may want to add more of them. Another
> example may be the check for abilities. We may want to relax/remove the
> capability require to set one of them. With an ABI version, the user can
> easily check if the current kernel support that.

Don't call it an ABI, perhaps minimum policy version (similar to 
what SELinux does).  Changes need to be made so that any existing 
userspace still works.



-- 
James Morris
<jmorris@namei.org>

--1665246916-1251487109-1503892121=:8842--
