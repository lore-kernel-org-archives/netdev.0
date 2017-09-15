From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: selftests/bpf doesn't compile
Date: Fri, 15 Sep 2017 09:02:55 -0700
Message-ID: <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp>
References: <20170908111923.27434-1-thomas@m3y3r.de>
 <20170908230155.esge2mctk5d5g7gb@ast-mbp>
 <59B32231.9090406@iogearbox.net>
 <ed20875b-7a01-fbc8-e8d1-3929ba35c8ac@kernel.org>
 <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Meyer <thomas@m3y3r.de>, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>,
        Networking <netdev@vger.kernel.org>
To: Shuah Khan <shuah@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2017 at 09:33:48AM -0600, Shuah Khan wrote:
> Hi Alexei and Daniel,
> 
> bpf test depends on clang and fails to compile when
> 
> ------------------------------------------------------
> make -C tools/testing/selftests/bpf run_tests
> 
> 
> make: clang: Command not found
> Makefile:39: recipe for target '.linux-kselftest/tools/testing/selftests/bpf/test_pkt_access.o' failed
> make: *** [./linux-kselftest/tools/testing/selftests/bpf/test_pkt_access.o] Error 127
> make: Leaving directory '.linux-kselftest/tools/testing/selftests/bpf'
> 
> With "make TARGETS=bpf kselftest" it fails earlier:
> 
> 
> make[3]: Entering directory './linux-kselftest/tools/lib/bpf'
> Makefile:40: tools/scripts/Makefile.arch: No such file or directory
> Makefile:84: tools/build/Makefile.feature: No such file or directory
> Makefile:143: tools/build/Makefile.include: No such file or directory
> make[3]: *** No rule to make target 'tools/build/Makefile.include'.  Stop.
> make[3]: Leaving directory '.linux-kselftest/tools/lib/bpf'
> Makefile:34: recipe for target './linux-kselftest/tools/testing/selftests/bpf/libbpf.a' failed
> make[2]: *** [./linux-kselftest/tools/testing/selftests/bpf/libbpf.a] Error 2
> make[2]: Leaving directory './linux-kselftest/tools/testing/selftests/bpf'
> Makefile:69: recipe for target 'all' failed
> make[1]: *** [all] Error 2
> Makefile:1190: recipe for target 'kselftest' failed
> make: *** [kselftest] Error 2
> 
> --------------------------------------------------------------
> 
> Is bpf test intended to be run in kselftest run? The clang dependency might
> not be met on majority of the systems. Is this a hard dependency??

It is a hard dependency and clang should be present on majority of the systems.
More details are in samples/bpf/README.rst
which was written long ago. Nowadays apt-get/yum will install clang
with bpf support builtin.

> Would it make sense to create a special target for bpf test? We do have a few
> tests that do that now. 
> 
> TARGETS_HOTPLUG = cpu-hotplug
> TARGETS_HOTPLUG += memory-hotplug
> 
> I could add a special target for bpf TARGET_BPF perhaps and exclude it from
> the run_tests.

I'm not sure what was the motivation to exclude hotplug from default testing,
since I think it diminishes the value of selftests overall.
Not running all tests all the time risks breaking them.
selftest makefile refactoring broke selftests/bpf in the past,
so I strongly suggest to install clang and make sure the tests are passing
on the test servers otherwise we'd need to move selftests/bpf out of
selftests to avoid further headaches for us when selftests infra keeps
changing.
