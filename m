From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH 00/20] kselftest install target feature
Date: Tue, 04 Nov 2014 16:45:18 -0700
Message-ID: <5459650E.6070201@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com> <CAGXu5jK9-TpOF4SFX2bkU2UJMXk-3W+-_we0BTxu4Ga+7bYXSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Marek <mmarek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>, tranmanphong@gmail.com,
	David Herrmann <dh.herrmann@gmail.com>,
	Hugh Dickins <hughd@google.com>, bobby.prani@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	linux-kbuild <linux-kbuild@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jK9-TpOF4SFX2bkU2UJMXk-3W+-_we0BTxu4Ga+7bYXSQ@mail.gmail.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/04/2014 12:22 PM, Kees Cook wrote:
> On Tue, Nov 4, 2014 at 9:10 AM, Shuah Khan <shuahkh@osg.samsung.com> wrote:
>> This patch series adds a new kselftest_install make target
>> to enable selftest install. When make kselftest_install is
>> run, selftests are installed on the system. A new install
>> target is added to selftests Makefile which will install
>> targets for the tests that are specified in INSTALL_TARGETS.
>> During install, a script is generated to run tests that are
>> installed. This script will be installed in the selftest install
>> directory. Individual test Makefiles are changed to add to the
>> script. This will allow new tests to add install and run test
>> commands to the generated kselftest script.
> 
> I'm all for making the self tests more available, but I don't think
> this is the right approach. My primary objection is that it creates a
> second way to run tests, and that means any changes and additions need
> to be updated in two places. I'd much rather just maintain the single
> "make" targets instead. Having "make" available on the target device
> doesn't seem too bad to me. Is there a reason that doesn't work for
> your situation?

Kees,

My primary objective is to provide a way to install selftests for a
specific kernel release. This will allow developers to run tests for
a specific release and look for regressions. Adding an install target
will also help support local execution of tests in a virtualized
environments. In some cases such as qemu, it is not practical to
expect the target to have support for "make". Once tests are installed
to be run outside the git environment, we need a master script that
can run the tests. Hence the need for a master script that can run
tests.

We have the ability to run all tests via make kselftest target or
run a specific test using the individual test's run_tests target.
Both of above are necessary to support running tests from the tree.
Embedding run_tests logic in the makefiles doesn't work very well
in the long run.

We also need a way to run them outside tree. I agree with you that
the way I added the script generation, duplicates the code in individual
run_tests targets and that changes/updates need to be made in both
places.

Would you be ok with the approach if I fixed the duplicating
problem? I can address the duplication concern easily.

> 
> I would, however, like to see some better standardization of the test
> "framework" that we've got in there already. (For example, some
> failures fail the "make", some don't, there are various reporting
> methods for success/failure depending on the test, etc.)

This is being addressed and I have the framework in linux-kselftest
git next branch at the moment. I do think the above work is part of
addressing the larger framework issues such as being able to run tests
on a target system that might not have "make" support and makes it
easier to use.

thanks,
-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
