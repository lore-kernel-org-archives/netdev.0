From: Markus Gutschke <markus@chromium.org>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 6 Apr 2012 14:32:09 -0700
Message-ID: <CAE6n16m+Z242wHZUR07RFJcou4-J=fYtokBb4wXHSXPPad7ffQ@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406124921.5754e941.akpm@linux-foundation.org>
 <CAE6n16m3v4BghY7GGwHCy2t-7-vmRpyOV6swap9GrMQnmGLroA@mail.gmail.com>
 <CAObL_7GzsJ+EW94oYG+EzcRqYyH2EPTyFgTgo6zmSz1yxEe-xw@mail.gmail.com>
 <CAE6n16=5fEBYP37R3XDFWL_8YOk7MH6T_CbuX3sZCpngD=v=rg@mail.gmail.com> <CAObL_7E7dHWxKgA7-pSCuUCrxEqY1H55Kxg_sF_OLbdx=pkT4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, jmorris@namei.org,
	Andy Lutomirski <luto@amacapital.net>
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAObL_7E7dHWxKgA7-pSCuUCrxEqY1H55Kxg_sF_OLbdx=pkT4g@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 14:15, Andrew Lutomirski <luto@mit.edu> wrote:
> Agreed, but I'm talking about something totally different: if I can
> use CLONE_NEWPID, then I can send an unexpected pid with SCM_CREDS.
> The SCM_CREDS receive code should remap pids.

Yes, I know. It's broken. And so is the view of the /proc filesystem
when inside a pid namespace. And things behave funny if you don't set
up a new "init" process inside of the pid namespace. And I am sure, a
few other things are broken that we just haven't run into.

CLONE_NEWPID is tricky. I can understand, if you want to fix it first.
Looking forward to seeing some patches in the future; please cc me, if
you want feedback from an actual user of this code.

The SCM_CREDS issue is the most serious one of the above, but it
doesn't bother me personally, as I would just set up my sandbox policy
to disallow all of SCM_CREDS (*). But that obviously not a good excuse
for leaving a kernel bug around.

Overall, I like both NO_NEW_PRIVS and BPF filters for seccomp though;
they are a great way to reduce the attack surface of the kernel.
Kernel bugs become a lot less of a headache, if I have a way to filter
out the buggy parts of the kernel. It isn't a panacea, but it's a
great new tool to harden applications.


Markus


*) this is currently difficult to filter SCM_CREDS, if we still want
to allow SCM_RIGHTS. See my earlier complaint about sendmsg().
Currently, filtering of sendmsg() probably requires the use of a
helper process.
