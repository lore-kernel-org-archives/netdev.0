From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: selftests/bpf doesn't compile
Date: Mon, 18 Sep 2017 15:31:32 +0200
Message-ID: <59BFCAB4.2060503@iogearbox.net>
References: <20170908111923.27434-1-thomas@m3y3r.de> <20170908230155.esge2mctk5d5g7gb@ast-mbp> <59B32231.9090406@iogearbox.net> <ed20875b-7a01-fbc8-e8d1-3929ba35c8ac@kernel.org> <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org> <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp> <701006c0-f80a-6bd7-fb5e-5bca1dc33a31@solarflare.com> <20170915180751.rnmvttf4lnz26qit@ast-mbp> <59BC1AAC.3040401@iogearbox.net> <59BC2069.8050100@iogearbox.net> <18942477-7824-046b-d26f-7272cf107c7f@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shuah Khan <shuah@kernel.org>, Thomas Meyer <thomas@m3y3r.de>,
        linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
        Networking <netdev@vger.kernel.org>
To: Shuah Khan <shuahkh@osg.samsung.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <18942477-7824-046b-d26f-7272cf107c7f@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/16/2017 12:41 AM, Shuah Khan wrote:
> On 09/15/2017 12:48 PM, Daniel Borkmann wrote:
>> On 09/15/2017 08:23 PM, Daniel Borkmann wrote:
>>> On 09/15/2017 08:07 PM, Alexei Starovoitov wrote:
>>>> On Fri, Sep 15, 2017 at 05:58:40PM +0100, Edward Cree wrote:
>>>>> On 15/09/17 17:02, Alexei Starovoitov wrote:
>>>>>> On Thu, Sep 14, 2017 at 09:33:48AM -0600, Shuah Khan wrote:
>>>>>>> Is bpf test intended to be run in kselftest run? The clang dependency might
>>>>>>> not be met on majority of the systems. Is this a hard dependency??
>>>>>> It is a hard dependency and clang should be present on majority of the systems.
>>>>> I think this is the wrong approach.  Making kselftest hard-require clang doesn't
>>>>>    mean that the bpf tests will be run more often, it means that the rest of the
>>>>>    kselftests will be run less often.  clang is quite big (when I tried to install
>>>>>    it on one of my test servers, I didn't have enough disk space & had to go on a
>>>>>    clear-out of unused packages), and most people aren't interested in the bpf
>>>>>    subsystem specifically; they would rather be able to skip those tests.
>>>>> I feel that as long as they know they are skipping some tests (so e.g. they
>>>>>    won't consider it a sufficient test of a kselftest refactor), that's fine.
>>>>> It's not even as though all of the bpf tests require clang; the (smaller) tests
>>>>>    written directly in raw eBPF instructions could still be run on such a system.
>>>>>    So I think we should attempt to run as much as possible but accept that clang
>>>>>    may not be available and have an option to skip some tests in that case.
>>>>
>>>> imo the value of selftests/bpf is twofold:
>>>> 1. it helps bpf developers avoid regressions
>>>> 2. as part of continuous integration it helps to catch bpf regressions
>>>> that were somehow caused by changes in other parts of the kernel
>>>>
>>>> If a developer didn't bother to satisfy all bpf tests dependencies
>>>> (which includes clang) and ran all tests before sending a patch,
>>>> I don't want to see such patches. It just wastes maintainers time
>>>> to review code and spot bugs that could have been caught by tests.
>>>> Collectively we invested years of work into these tests and
>>>> developers better take advantage of it by running all.
>>>
>>> +1
>>>
>>>> If a CI server didn't satisfy all bpf test dependencies,
>>>> I don't want such CI setup to be running and reporting results,
>>>> since it will give false sense of test coverage.
>>>> Test failures due to missing dependencies are hard failures.
>>>> We cannot skip them.
>>>
>>> +1
>>
>> Btw, on that note, the folks from zero-day bot run the BPF kselftests
>> for a while now just fine and they do run them together with clang,
>> so they have the full, proper coverage how it should be. It's not
>> how it used to be in the early days, you can just go and install
>> llvm/clang package on all the major distros today and you get the
>> bpf target by default enabled already.
>>
>>>> I'd like generic XDP tests to be added to selftests/bpf which
>>>> would mean that the latest iproute2 will become a hard dependency
>>>> and bpf developers and CI host owners would need to upgrade
>>>> their iproute2.
>>>> The tests either pass or fail. Skipping them due to missing
>>>> dependencies is the same as fail and in that sense I don't want
>>>> to change selftests/bpf/Makefile to make it skip clang.
>>>
>>> I fully agree that for the BPF selftests it is very desirable
>>> to not only test the verifier with couple of BPF insn snippets,
>>> but to actually load and run programs that more closely resemble
>>> real world programs. For more complex interactions these snippets
>>> are just limited, think of tail calls, testing perf event output
>>> helper, etc, which would all require to write these tests with
>>> restricted C when we add them (unless we want to make writing
>>> these tests a real pain ;) in which case no-one will bother to
>>> write tests at all for them). Mid to long term I would definitely
>>> like to see more programs in BPF selftests (e.g. moved over from
>>> samples/bpf/) to increase the test coverage.
>
> As I said in my earlier email:
>
> Unless users choose to install clang, bpf will always fail run without
> clang. So clang dependency is an issue for bpf test coverage in general.
> That is your choice as to whether you want to increase the scope of
> regression test coverage for bpf or not.
>
> I fully understand you have weigh that against ease of writing tests.
>
> We can leave things the way they are since:
>
> - You can't force users to install clang and run bpf test. Users might
>    opt for letting bpf test fail due to unmet dependency.
>
> - You have reasons to continue use clang and you have been using it for
>    a longtime.

I'm definitely for leaving it as it currently is and having clang as
hard dependency; there will be more BPF selftests over time that will
require to compile BPF progs (through clang's BPF backend) written in
restricted C, so just skipping these tests would give a false sense
of coverage. clang is pretty much needed anyway for writing more complex
programs, thus leaving requirements the way they are is the much better
option.

> I will try to see why make ksefltest fails on bpf even with my patch
> series that addresses the source directory issue. All other tests build
> and run. It is not an issue with bpf specifically, it is something that
> has never been tested in this use-case.

Great, thanks!
