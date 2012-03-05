From: Serge Hallyn <serge@hallyn.com>
Subject: Re: [PATCH v12 07/13] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 05 Mar 2012 15:13:08 -0600
Message-ID: <1330981988.1484.9.camel@Nokia-N900-51-1>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	 <1330559620-23543-7-git-send-email-wad@chromium.org>
	 <20120302182455.GA11308@mail.hallyn.com>
	  <CABqD9ha8o3JU0v0ZnKcsjqm8osjSiUfCyvc=vrxhDTHHuG_V4A@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,  linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,  netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,  hpa@zytor.com, mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,  rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,  eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,  scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,  corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,  coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1045-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Reply-To: Serge Hallyn <serge@hallyn.com>
In-Reply-To: <CABqD9ha8o3JU0v0ZnKcsjqm8osjSiUfCyvc=vrxhDTHHuG_V4A@mail.gmail.com>
Content-ID: <1330981987.1484.8.camel@Nokia-N900-51-1>
List-Id: netdev.vger.kernel.org


----- Original message -----
> On Fri, Mar 2, 2012 at 12:24 PM, Serge E. Hallyn <serge@hallyn.com>
> wrote:
> > Quoting Will Drewry (wad@chromium.org):
> > > This change adds the SECCOMP_RET_ERRNO as a valid return value from a
> > > seccomp filter.  Additionally, it makes the first use of the lower
> > > 16-bits for storing a filter-supplied errno.  16-bits is more than
> > > enough for the errno-base.h calls.
> > > 
> > > Returning errors instead of immediately terminating processes that
> > > violate seccomp policy allow for broader use of this functionality
> > > for kernel attack surface reduction.  For example, a linux container
> > > could maintain a whitelist of pre-existing system calls but drop
> > > all new ones with errnos.  This would keep a logically static attack
> > > surface while providing errnos that may allow for graceful failure
> > > without the downside of do_exit() on a bad call.
> > > 
> > > v12: - move to WARN_ON if filter is NULL
> > >        (oleg@redhat.com, luto@mit.edu, keescook@chromium.org)
> > >      - return immediately for filter==NULL (keescook@chromium.org)
> > >      - change evaluation to only compare the ACTION so that layered
> > >        errnos don't result in the lowest one being returned.
> > >        (keeschook@chromium.org)
> > > v11: - check for NULL filter (keescook@chromium.org)
> > > v10: - change loaders to fn
> > >  v9: - n/a
> > >  v8: - update Kconfig to note new need for syscall_set_return_value.
> > >      - reordered such that TRAP behavior follows on later.
> > >      - made the for loop a little less indent-y
> > >  v7: - introduced
> > > 
> > > Reviewed-by: Kees Cook <keescook@chromium.org>
> > > Signed-off-by: Will Drewry <wad@chromium.org>
> > 
> > Clever :)
> > 
> > Thanks, Will.
> > 
> > For patches 1-7,
> > 
> > Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> 
> Thanks!
> 
> > The -1 return value from __secure_computing_int() seems like it
> > could stand  #define, like
> > 
> > #define SECCOMP_DONTRUN -1
> > #define SECCOMP_RUN 0
> > 
> > or something Maybe not, but -1 always scares me and I had to look back
> > and forth a few times to make sure it was doing what I would want.
> 
> Works for me.   The -1 just matches what syscall emulation, etc does on
> x86.   I'll add this to the tweaks for v14.
> 
> Thanks!

Well, in that case maybe it's not worth it.  Sounds
like ignorance on my part.

thanks,
-serge
