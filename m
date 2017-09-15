From: Edward Cree <ecree@solarflare.com>
Subject: Re: selftests/bpf doesn't compile
Date: Fri, 15 Sep 2017 17:58:40 +0100
Message-ID: <701006c0-f80a-6bd7-fb5e-5bca1dc33a31@solarflare.com>
References: <20170908111923.27434-1-thomas@m3y3r.de>
 <20170908230155.esge2mctk5d5g7gb@ast-mbp> <59B32231.9090406@iogearbox.net>
 <ed20875b-7a01-fbc8-e8d1-3929ba35c8ac@kernel.org>
 <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org>
 <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Meyer <thomas@m3y3r.de>, <linux-kernel@vger.kernel.org>,
        <linux-kselftest@vger.kernel.org>,
        Shuah Khan <shuahkh@osg.samsung.com>,
        Networking <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Shuah Khan <shuah@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/09/17 17:02, Alexei Starovoitov wrote:
> On Thu, Sep 14, 2017 at 09:33:48AM -0600, Shuah Khan wrote:
>> Is bpf test intended to be run in kselftest run? The clang dependency might
>> not be met on majority of the systems. Is this a hard dependency??
> It is a hard dependency and clang should be present on majority of the systems.
I think this is the wrong approach.  Making kselftest hard-require clang doesn't
 mean that the bpf tests will be run more often, it means that the rest of the
 kselftests will be run less often.  clang is quite big (when I tried to install
 it on one of my test servers, I didn't have enough disk space & had to go on a
 clear-out of unused packages), and most people aren't interested in the bpf
 subsystem specifically; they would rather be able to skip those tests.
I feel that as long as they know they are skipping some tests (so e.g. they
 won't consider it a sufficient test of a kselftest refactor), that's fine.
It's not even as though all of the bpf tests require clang; the (smaller) tests
 written directly in raw eBPF instructions could still be run on such a system.
 So I think we should attempt to run as much as possible but accept that clang
 may not be available and have an option to skip some tests in that case.

-Ed
