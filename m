From: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Subject: Re: [PATCH v3 00/20] kselftest install target feature
Date: Mon, 29 Dec 2014 15:53:10 +1100
Message-ID: <1419828790.26911.3.camel@ellerman.id.au>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tim.bird-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1419387513.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-24 at 09:27 -0700, Shuah Khan wrote:
> This patch series adds a new kselftest_install make target
> to enable selftest install. When make kselftest_install is
> run, selftests are installed on the system. A new install
> target is added to selftests Makefile which will install
> targets for the tests that are specified in INSTALL_TARGETS.
> During install, a script is generated to run tests that are
> installed. This script will be installed in the selftest install
> directory. Individual test Makefiles are changed to add to the
> script. This will allow new tests to add install and run test
> commands to the generated kselftest script. kselftest target
> now depends on kselftest_install and runs the generated kselftest
> script to reduce duplicate work and for common look and feel when
> running tests.
> 
> This approach leverages and extends the existing framework that
> uses makefile targets to implement run_tests and adds install
> target. This will scale well as new tests get added and makes
> it easier for test writers to add install target at the same
> time new test gets added.
> 
> This v3 series reduces duplicate code to generate script
> in indiviual test Makefiles and consolidates support in
> selftests main Makefile. In the main Makefile, it does
> minimal work to set and export install path. In this
> series exec and powerpc tests are not included in the
> install, this work will be done in future patches. exec
> and powerpc are still run when make kselftest is invoked.

Any particular reason you excluded the powerpc tests? Going by a quick count,
powerpc has 32 of the 54 self tests, ie. more than half.

Sorry I didn't get a chance to review v1 or v2, but is this really the best
solution we can come up with? It seems to involve a lot of boiler plate getting
repeated in every Makefile.

I'm off this week so I can't immediately come up with something better, I'll
try in the new year.

cheers
