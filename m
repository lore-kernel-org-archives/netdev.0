From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/6] selftests: Introduce minimal shared logic for
 running tests
Date: Mon, 19 Jan 2015 11:35:42 +1100
Message-ID: <1421627742.3787.6.camel@ellerman.id.au>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
	 <54B95006.3080502@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mmarek@suse.cz,
	gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	rostedt@goodmis.org, mingo@redhat.com, davem@davemloft.net,
	keescook@chromium.org, tranmanphong@gmail.com, cov@codeaurora.org,
	dh.herrmann@gmail.com, hughd@google.com, bobby.prani@gmail.com,
	serge.hallyn@ubuntu.com, ebiederm@xmission.com,
	tim.bird@sonymobile.com, josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B95006.3080502@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-01-16 at 10:53 -0700, Shuah Khan wrote:
> On 01/09/2015 02:06 AM, Michael Ellerman wrote:
> > This adds a Make include file which most selftests can then include to
> > get the run_tests logic.
> > 
> > On its own this has the advantage of some reduction in repetition, and
> > also means the pass/fail message is defined in fewer places.
> > 
> > However the key advantage is it will allow us to implement install very
> > simply in a subsequent patch.
> > 
> > The default implementation just executes each program in $(TEST_PROGS).
> > 
> > We use a variable to hold the default implementation of $(RUN_TESTS)
> > because that gives us a clean way to override it if necessary, ie. using
> > override. The mount, memory-hotplug and mqueue tests use that to provide
> > a different implementation.
> > 
> > Tests are not run via /bin/bash, so if they are scripts they must be
> > executable, we add u+x to several.
> > 
> > Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> 
> I like the shared logic approach in general provided it leaves the
> flexibility to not use the shared logic if a test have the need to
> do so.

Yes of course it does, it's entirely optional to include lib.mk.

> This series requires some patch planning. shared logic patch
> followed by individual test patches as opposed a single patch.

It could be a single patch too, but there's no reason to do it that way. The
series works fine as I sent it.

> I would like to see the shared logic work done on top of my patch v4
> series.

That's a waste of time. This series replaces your v4. Doing this "on top" of
your v4 would just mean reverting your v4 series and then applying this.

cheers
