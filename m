From: Sumit Semwal <sumit.semwal@linaro.org>
Subject: Re: latest kselftest with stable tree: bpf failures
Date: Mon, 7 Aug 2017 22:11:20 +0530
Message-ID: <CAO_48GEe=z94RxARZet6oOZqON0B1LOPRE1GBre1udC1rteS_w@mail.gmail.com>
References: <CAO_48GFVH_ciiJRuse55hp2sARYDd0hGncfRembnBCYd_re0JQ@mail.gmail.com>
 <59833EF2.2040203@iogearbox.net> <CAO_48GHFSa4bkfvEsukJ5snc5F8cXjhp+K9CcZDxOijD-Jo0Ag@mail.gmail.com>
 <5984BE63.7040608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: ast@kernel.org, netdev@vger.kernel.org,
        "# 3.4.x" <stable@vger.kernel.org>,
        "open list:KERNEL SELFTEST FRAMEWORK <linux-kselftest@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Shuah Khan"
        <shuah@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5984BE63.7040608@iogearbox.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Daniel,


On 5 August 2017 at 00:05, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/03/2017 05:34 PM, Sumit Semwal wrote:
>>
>> On 3 August 2017 at 20:49, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>>
>>> On 08/03/2017 05:09 PM, Sumit Semwal wrote:
>>>>
>>>>
>>>> Hello Alexei, Daniel, and the bpf community,
>>>>
>>>> As part of trying to improve stable kernels' testing, we're running
>>>> ~current kselftests with stable kernels (4.4 and 4.9 for now), and
>>>> reporting issues.
>>>
>>>
>>> Thanks for the report, I haven't been tracking the BPF testsuite
>>> with stable kernels much so far. I will take a look! Just to clarify,
>>> with '~current kselftests' you mean the one in current Linus' tree
>>> or the ones corresponding to the 4.4 and 4.9 -stable kernels?
>>
>> I meant current Linus's release (4.12) atm.
>
>
> Thanks for clarifying that, hmm. Why not running the
> selftests that are tied to the actual -stable kernel,
> meaning those that the corresponding kernel ships? Is
> the assumption that potentially you might have more
> coverage on Linus' tree directly, or that test cases
> are not updated via -stable along with fixes?

Thanks so much for your reply!
[1] has details of this discussion, but in summary, yes, it's
primarily the former - test cases have shown more coverage when tested
with Linus' tree in most cases.
>
> I looked at some of the SKIP cases, and how to tie that
> to the BPF tests (the suite runs probably over 1k tests
> on verifier, interpreter, jit, etc combinations currently).
> E.g. in some cases the verifier gets smarter and tests that
> are rejected on older kernels get accepted on newer ones.
> But then, we also wouldn't want to exclude these tests
> (e.g. based on kernel version number or such) for older
> kernels for the sake of making sure that in case stable
> updates are applied that they don't introduce regressions
> we'd otherwise could miss.
No, certainly not - but would there be some way to denote this
'smartness' as a feature, so we could test against the feature itself,
and not rely on kernel version?
>
> Then, mostly for testing JITs there's the test_bpf.c kernel
> module, which is a moving target as well, f.e. cleanups
> like de77b966ce8a ("net: introduce __skb_put_[zero, data,
> u8]") [unintentionally] tie this to a specific kernel version
> again. But then again, skipping test_bpf we'd potentially
> miss to run important test cases. For the mainline git tree
> it's fairly easy as the test suite is directly coupled to
> it. Hm, I don't have a good, reliably idea for the time
> being to not make this a maintenance/testing mess long
> term, so my recommendation for the time being would be
> to test with 4.4 and 4.9 test suites, but I'm definitely
> open for ideas to brainstorm.
>
Would it be possible to have test_bpf differentiate between SKIP (for
missing feature) and actual FAIL for the features it is testing? And
in case there are 0 FAILS, perhaps it could return success? There are
a few examples in selftests which are quite robust that ways.

I understand completely that it could feel like wasted effort, but
IMHO, tying tests to kernel versions rather than features can get into
a bigger maintenance issue.

> Thanks,
> Daniel

Best,
Sumit.

[1]: https://lkml.org/lkml/2017/6/16/691
