From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 00/20] kselftest install target feature
Date: Tue, 4 Nov 2014 11:22:57 -0800
Message-ID: <CAGXu5jK9-TpOF4SFX2bkU2UJMXk-3W+-_we0BTxu4Ga+7bYXSQ@mail.gmail.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	linux-kbuild <linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1415117102.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2014 at 9:10 AM, Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org> wrote:
> This patch series adds a new kselftest_install make target
> to enable selftest install. When make kselftest_install is
> run, selftests are installed on the system. A new install
> target is added to selftests Makefile which will install
> targets for the tests that are specified in INSTALL_TARGETS.
> During install, a script is generated to run tests that are
> installed. This script will be installed in the selftest install
> directory. Individual test Makefiles are changed to add to the
> script. This will allow new tests to add install and run test
> commands to the generated kselftest script.

I'm all for making the self tests more available, but I don't think
this is the right approach. My primary objection is that it creates a
second way to run tests, and that means any changes and additions need
to be updated in two places. I'd much rather just maintain the single
"make" targets instead. Having "make" available on the target device
doesn't seem too bad to me. Is there a reason that doesn't work for
your situation?

I would, however, like to see some better standardization of the test
"framework" that we've got in there already. (For example, some
failures fail the "make", some don't, there are various reporting
methods for success/failure depending on the test, etc.)

-Kees

> Approach:
>
> make kselftest_target:
> -- exports kselftest INSTALL_KSFT_PATH
>    default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
> -- exports path for ksefltest.sh
> -- runs selftests make install target:
>
> selftests make install target
> -- creates kselftest.sh script in install install dir
> -- runs install targets for all INSTALL_TARGETS
>
> Individual test make install targets:
> -- install test programs and/or scripts in install dir
> -- append to the ksefltest.sh file to add commands to run test
>
> Shuah Khan (20):
>   selftests/user: move test out of Makefile into a shell script
>   selftests/net: move test out of Makefile into a shell script
>   kbuild: kselftest_install - add a new make target to install selftests
>   selftests: add install target to enable installing selftests
>   selftests/breakpoints: add install target to enable installing test
>   selftests/cpu-hotplug: add install target to enable installing test
>   selftests/efivarfs: add install target to enable installing test
>   selftests/firmware: add install target to enable installing test
>   selftests/ipc: add install target to enable installing test
>   selftests/kcmp: add install target to enable installing test
>   selftests/memfd: add install target to enable installing test
>   selftests/memory-hotplug: add install target to enable installing test
>   selftests/mount: add install target to enable installing test
>   selftests/mqueue: add install target to enable installing test
>   selftests/net: add install target to enable installing test
>   selftests/ptrace: add install target to enable installing test
>   selftests/sysctl: add install target to enable installing test
>   selftests/timers: add install target to enable installing test
>   selftests/vm: add install target to enable installing test
>   selftests/user: add install target to enable installing test
>
>  Makefile                                        | 17 +++++++++++++++++
>  tools/testing/selftests/Makefile                | 14 ++++++++++++++
>  tools/testing/selftests/breakpoints/Makefile    | 12 ++++++++++++
>  tools/testing/selftests/cpu-hotplug/Makefile    |  9 +++++++++
>  tools/testing/selftests/efivarfs/Makefile       | 13 ++++++++++++-
>  tools/testing/selftests/firmware/Makefile       | 20 ++++++++++++++++++++
>  tools/testing/selftests/ipc/Makefile            | 11 +++++++++++
>  tools/testing/selftests/kcmp/Makefile           | 12 ++++++++++++
>  tools/testing/selftests/memfd/Makefile          | 10 ++++++++++
>  tools/testing/selftests/memory-hotplug/Makefile |  9 +++++++++
>  tools/testing/selftests/mount/Makefile          |  7 +++++++
>  tools/testing/selftests/mqueue/Makefile         |  8 ++++++++
>  tools/testing/selftests/net/Makefile            | 18 +++++++++++-------
>  tools/testing/selftests/net/test_bpf.sh         | 10 ++++++++++
>  tools/testing/selftests/ptrace/Makefile         | 11 +++++++++--
>  tools/testing/selftests/sysctl/Makefile         | 10 ++++++++++
>  tools/testing/selftests/timers/Makefile         |  7 +++++++
>  tools/testing/selftests/user/Makefile           | 15 ++++++++-------
>  tools/testing/selftests/user/test_user_copy.sh  | 10 ++++++++++
>  tools/testing/selftests/vm/Makefile             |  7 +++++++
>  20 files changed, 213 insertions(+), 17 deletions(-)
>  create mode 100755 tools/testing/selftests/net/test_bpf.sh
>  create mode 100755 tools/testing/selftests/user/test_user_copy.sh
>
> --
> 1.9.1
>



-- 
Kees Cook
Chrome OS Security
