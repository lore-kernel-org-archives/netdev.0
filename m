From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 6 Apr 2012 14:15:19 -0700
Message-ID: <CAObL_7E7dHWxKgA7-pSCuUCrxEqY1H55Kxg_sF_OLbdx=pkT4g@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406124921.5754e941.akpm@linux-foundation.org>
 <CAE6n16m3v4BghY7GGwHCy2t-7-vmRpyOV6swap9GrMQnmGLroA@mail.gmail.com>
 <CAObL_7GzsJ+EW94oYG+EzcRqYyH2EPTyFgTgo6zmSz1yxEe-xw@mail.gmail.com> <CAE6n16=5fEBYP37R3XDFWL_8YOk7MH6T_CbuX3sZCpngD=v=rg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@linux-foundation.org>, Will Drewry <wad@chromium.org>,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, corbet@lwn.net, eric.dumazet@gmail.com,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org,
	Andy Lutomirski <luto@amacapital.net>
To: Markus Gutschke <markus@chromium.org>
Return-path: <kernel-hardening-return-1211-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: amluto@gmail.com
In-Reply-To: <CAE6n16=5fEBYP37R3XDFWL_8YOk7MH6T_CbuX3sZCpngD=v=rg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 2:04 PM, Markus Gutschke <markus@chromium.org> wrote=
:
> On Fri, Apr 6, 2012 at 13:54, Andrew Lutomirski <luto@mit.edu> wrote:
>> (FWIW, I think that CLONE_NEWPID interacts badly with unix socket
>> credentials and should be fixed as a prerequisite for making it easier
>> to access.)
>
> sendmsg() is a big hair ball. And yes, I have all sorts of things on
> my wish list that touch sendmsg(). I don't think, I'll get them
> fullfilled anytime soon, though:
>
> =A0- sendmsg() does lots of different things: sending on unconnected
> sockets, sending file descriptors, sending unix decriptors, and
> plain-old sending data. These operations have very different security
> properties and implications. It would be awesome if BPF filters could
> filter these different types of operations selectively.
>
> =A0- ancillary data is a cool concept in general. We should use it more.
> If I could send a memory mapping from one process to another, that
> would solve so many problems. But I know, I am dreaming; I don't
> expect to see this feature any time soon.
>

Agreed, but I'm talking about something totally different: if I can
use CLONE_NEWPID, then I can send an unexpected pid with SCM_CREDS.
The SCM_CREDS receive code should remap pids.

--Andy
