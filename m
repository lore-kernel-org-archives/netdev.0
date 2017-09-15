From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: selftests/bpf doesn't compile
Date: Fri, 15 Sep 2017 16:32:45 -0600
Message-ID: <498a6b85-01ea-5c69-acf5-7cbaf5b5396e@osg.samsung.com>
References: <20170908111923.27434-1-thomas@m3y3r.de>
 <20170908230155.esge2mctk5d5g7gb@ast-mbp> <59B32231.9090406@iogearbox.net>
 <ed20875b-7a01-fbc8-e8d1-3929ba35c8ac@kernel.org>
 <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org>
 <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp>
 <e07dabee-6c9c-7842-65b0-990a2ed1a2e9@osg.samsung.com>
 <20170915181440.adkgyqbt4yxrnbw7@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shuah Khan <shuah@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Meyer <thomas@m3y3r.de>, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Networking <netdev@vger.kernel.org>,
        Shuah Khan <shuahkh@osg.samsung.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170915181440.adkgyqbt4yxrnbw7@ast-mbp>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/2017 12:14 PM, Alexei Starovoitov wrote:
> On Fri, Sep 15, 2017 at 11:00:31AM -0600, Shuah Khan wrote:
>>>> I could add a special target for bpf TARGET_BPF perhaps and exclude it from
>>>> the run_test> 
>>> I'm not sure what was the motivation to exclude hotplug from default testing,
>>
>> These are considered a bit more disruptive and were excluded a while
>> back. These take cpus and memory on and off-line. Also require
>> root access. So even if they are included in the regular run, these
>> won't run.
> 
> most of bpf tests require root access as well.
> 
>> The first failure due to clang dependency is not a problem. The second one
>> in the case of "make kselftest" is the one that requires some work when bpf
>> make is run from the main Makefile. A lots of users run tests using the
>> kselftest target from the mail Makefile. hence I would like to get this
>> working, so it would be easier to run this test on test servers.
> 
> 'make kselftest' doesn't work for me at all, since I suspect it
> assumes in-source build. I always use KBUILD_OUTPUT,
> since I build multiple archs with different configs out of the same
> source tree, so there is a bigger problem here.

Right. I think you probably use

make KBUILD_OUTPUT=dir -C tools/testing/selftests/bpf

> 
> $ make kselftest
> make[1]: Entering directory `/data/users/ast/net-next/bld_x64'
> make: Entering an unknown directory
> make: *** tools/testing/selftests: No such file or directory.  Stop.
> make: Leaving an unknown directory
> make[1]: *** [kselftest] Error 2
> make[1]: Leaving directory `/data/users/ast/net-next/bld_x64'
> make: *** [sub-make] Error 2
> 

Right. There is patch set out to fix this problem which I sent out couple
of days ago. It is probably the case that bpf Makefile might need changes
to build when it is built from the sleftests/Makefile or the main Makefile.

thanks,
-- Shuah
