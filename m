From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH v2 07/19] selftests/firmware: add install target to enable
 installing test
Date: Tue, 11 Nov 2014 18:06:43 -0700
Message-ID: <5462B2A3.9000007@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com> <1d2d13556ddbbbbb13989cdcb08447909bc4afaf.1415735831.git.shuahkh@osg.samsung.com> <CAGXu5j+yLqH0xj=5N90LRmK9F1xPLVWBy+cyUCzjvKJH7gE7AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Marek <mmarek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>,
	Phong Tran <tranmanphong@gmail.com>,
	David Herrmann <dh.herrmann@gmail.com>,
	Hugh Dickins <hughd@google.com>,
	pranith kumar <bobby.prani@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	linux-kbuild <linux-kbuild@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5j+yLqH0xj=5N90LRmK9F1xPLVWBy+cyUCzjvKJH7gE7AA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/11/2014 02:29 PM, Kees Cook wrote:
> Hi,
> 
> Sorry, I still really don't like this approach. While it is all in one
> place (thank you for that), I think it isn't a form that is very
> workable for the people maintaining the self tests. How about this,
> instead of per-Makefile customization, why not define an execution
> framework for these tests instead.

If I understand correctly, sounds like you don't like the way
install target is implemented in the individual test Makefiles
and the changes I made to run_tests targets to address the code
duplication concern.

At the moment there is no duplicate code in this patch series
between install and run_tests targets. This is a  first step
towards standardizing the framework and a definite improvement
over what we have currently. As I mentioned earlier, my goal
is to make it easier for developers to install and run the
existing tests and evolve the framework as we go.

Assuming my understanding is correct that:

-- install and run_tests targets in individual tests can be
   refined and automated with a common Makefile approach you
   proposed.
-- the rest of the user-interface kselftest_install and kselftest
   are good.

I would like to propose that we get started with the current
implementation and refine it based on the following ideas you
suggested. The refinements you are recommending are confined
to selftests and can be made after the kselftest_install
gets added. Adding kselftest_install makes it easier to make
the refinements as it defines overall UI.

> 
> For example, how about every test directory must have a Makefile with
> the needed binary targets. A common makefile could be included that
> defines the "run_tests" target that calls the script "run_tests.sh"
> that is a shell script in the current directory. (For inspiration, see
> how kernel modules can be built out of tree.)
> 
> The "run_tests.sh" scripts could all include a common shell script,
> say "../common.sh" that provides any common variables, functions, etc
> (e.g. things like "Start $name test ..." should be in common.sh
> instead of repeated in every script, the installation logic can be in
> once place instead of repeated).
> 
> Then along side common.sh could be "run_installed_tests.sh" or
> something, used on the installed target, that would traverse each
> directory, etc. From this, we can have a much more data-driven
> framework, and a common approach to running tests.
> 
> As such, we should declare up front how tests should behave on
> failure. And the top-level test runner can do things like count the
> number of tests, failures, etc.
> 
> Then, instead of splitting up the patches by test directory, you can
> split them up by logical changes (e.g. defining the common "run_tests"
> target, and then removing the target from all the tests by including
> the common makefile stub that defines it).
> 

These are good ideas and I am with on evolving the framework to make
it easier to maintain individual tests. Patches are welcome.

thanks,
-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
