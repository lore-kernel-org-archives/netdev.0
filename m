From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: selftests/bpf doesn't compile
Date: Fri, 15 Sep 2017 11:07:53 -0700
Message-ID: <20170915180751.rnmvttf4lnz26qit@ast-mbp>
References: <20170908111923.27434-1-thomas@m3y3r.de>
 <20170908230155.esge2mctk5d5g7gb@ast-mbp>
 <59B32231.9090406@iogearbox.net>
 <ed20875b-7a01-fbc8-e8d1-3929ba35c8ac@kernel.org>
 <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org>
 <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp>
 <701006c0-f80a-6bd7-fb5e-5bca1dc33a31@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shuah Khan <shuah@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Meyer <thomas@m3y3r.de>, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>,
        Networking <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <701006c0-f80a-6bd7-fb5e-5bca1dc33a31@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 15, 2017 at 05:58:40PM +0100, Edward Cree wrote:
> On 15/09/17 17:02, Alexei Starovoitov wrote:
> > On Thu, Sep 14, 2017 at 09:33:48AM -0600, Shuah Khan wrote:
> >> Is bpf test intended to be run in kselftest run? The clang dependency might
> >> not be met on majority of the systems. Is this a hard dependency??
> > It is a hard dependency and clang should be present on majority of the systems.
> I think this is the wrong approach.  Making kselftest hard-require clang doesn't
>  mean that the bpf tests will be run more often, it means that the rest of the
>  kselftests will be run less often.  clang is quite big (when I tried to install
>  it on one of my test servers, I didn't have enough disk space & had to go on a
>  clear-out of unused packages), and most people aren't interested in the bpf
>  subsystem specifically; they would rather be able to skip those tests.
> I feel that as long as they know they are skipping some tests (so e.g. they
>  won't consider it a sufficient test of a kselftest refactor), that's fine.
> It's not even as though all of the bpf tests require clang; the (smaller) tests
>  written directly in raw eBPF instructions could still be run on such a system.
>  So I think we should attempt to run as much as possible but accept that clang
>  may not be available and have an option to skip some tests in that case.

imo the value of selftests/bpf is twofold:
1. it helps bpf developers avoid regressions
2. as part of continuous integration it helps to catch bpf regressions
that were somehow caused by changes in other parts of the kernel

If a developer didn't bother to satisfy all bpf tests dependencies
(which includes clang) and ran all tests before sending a patch,
I don't want to see such patches. It just wastes maintainers time
to review code and spot bugs that could have been caught by tests.
Collectively we invested years of work into these tests and
developers better take advantage of it by running all.

If a CI server didn't satisfy all bpf test dependencies,
I don't want such CI setup to be running and reporting results,
since it will give false sense of test coverage.
Test failures due to missing dependencies are hard failures.
We cannot skip them.

I'd like generic XDP tests to be added to selftests/bpf which
would mean that the latest iproute2 will become a hard dependency
and bpf developers and CI host owners would need to upgrade
their iproute2.
The tests either pass or fail. Skipping them due to missing
dependencies is the same as fail and in that sense I don't want
to change selftests/bpf/Makefile to make it skip clang.
