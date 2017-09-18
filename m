From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 3/3] selftests: silence test output by default
Date: Mon, 18 Sep 2017 14:24:27 -0400
Message-ID: <20170918182426.cs4wxy3igfx7zyvb@destiny>
References: <1505755982-7855-1-git-send-email-jbacik@fb.com>
 <1505756224-8187-1-git-send-email-jbacik@fb.com>
 <e8b067d2-9cef-2f3c-78a5-d6630aa765c1@kernel.org>
 <20170918175254.lsdzqvjm4uvix4rj@destiny>
 <ed8261a2-557a-cf1c-7298-d530bb7861d0@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josef Bacik <josef@toxicpanda.com>, Shuah Khan <shuah@kernel.org>,
        Josef Bacik <jbacik@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
        netdev@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ed8261a2-557a-cf1c-7298-d530bb7861d0@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 12:13:40PM -0600, Shuah Khan wrote:
> On 09/18/2017 11:52 AM, Josef Bacik wrote:
> > On Mon, Sep 18, 2017 at 11:46:18AM -0600, Shuah Khan wrote:
> >> On 09/18/2017 11:37 AM, josef@toxicpanda.com wrote:
> >>> From: Josef Bacik <jbacik@fb.com>
> >>>
> >>> Some of the networking tests are very noisy and make it impossible to
> >>> see if we actually passed the tests as they run.  Default to suppressing
> >>> the output from any tests run in order to make it easier to track what
> >>> failed.
> >>>
> >>> Signed-off-by: Josef Bacik <jbacik@fb.com>
> >>> --
> >>
> >> This change suppresses pass/fail wrapper output for all tests, not just the
> >> networking tests.
> >>
> >> Could you please send me before and after results for what you are trying
> >> to fix.
> >>
> > 
> > Yeah I wanted to suppress extraneous output from everybody, I just happened to
> > notice it because I was testing net.  The default thing already spits out what
> > it's running and pass/fail, there's no need to include all of the random output
> > unless the user wants to go and run the test manually.  As it is now it's
> > _impossible_ to tell what ran and what passed/failed because of all the random
> > output.
> 
> Unfortunately kselftests have lots of users that want different things. A recent
> request is to use TAP13 format for output for external parsers to be able to parse.
> That is what this change to add TAP13 header does.
> 
> The output you are seeing is the TAP 13 format to indicate the test has passed.
> 
> The right fix would be to suppress the Pass/Fail from the individual shell script
> and have the shell script exit with error code. kselftest lib.mk will handle the
> error code and print out pass/fail like it is doing now.
> 
> Using the common logic will help avoid duplicate code in tests/test scripts and
> also makes the pass/fail messages consistent.
> 
> In the following output the individual test output can be eliminated since lib.mk
> run_tests does that for you. In addition, you will also get a count of tests at
> the end of the run of all tests in a test directory.
> 
> TAP version 13
> selftests: run_netsocktests
> ========================================
> --------------------
> running socket test
> --------------------
> [PASS]
> ok 1..1 selftests: run_netsocktests [PASS]
> selftests: run_afpackettests
> ========================================
> must be run as root
> ok 1..2 selftests: run_afpackettests [PASS]
> selftests: test_bpf.sh
> ========================================
> test_bpf: [FAIL]
> not ok 1..3 selftests:  test_bpf.sh [FAIL]
> selftests: netdevice.sh
> ========================================
> SKIP: Need root privileges
> ok 1..4 selftests: netdevice.sh [PASS]
> 
> If you eliminate that you will just see the common lib.mk results.
> 
> TAP version 13
> selftests: run_netsocktests
> ========================================
> ok 1..1 selftests: run_netsocktests [PASS]
> selftests: run_afpackettests
> ========================================
> must be run as root
> ok 1..2 selftests: run_afpackettests [PASS]
> ========================================
> selftests: test_bpf.sh
> ========================================
> not ok 1..3 selftests:  test_bpf.sh [FAIL]
> selftests: netdevice.sh
> ========================================
> SKIP: Need root privileges
> ok 1..4 selftests: netdevice.sh [PASS]
> 
> 
> If you would like to fix the duplicate output, please send me patches
> to remove pass/fail output strings from tests instead. It is on my
> todo to do that this release.
> 

I'm confused, this is exactly what my patch does, it strips all of the
extraneous output and leaves only the TAP13 output.  Here is the output without
my suppression patch

https://da.gd/pup0

and here is the output with my suppression patch

https://da.gd/3olKj

Unless I'm missing something subtle it appears to be exactly the output you
want, without the random crap from the other tests.  The only thing I'm
redirecting is the output of the _test_ itself, $$BASENAME_TEST from what I can
tell is the actual test we're running, not the wrapper, so everything is as it
should be.  Thanks,

Josef
