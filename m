From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH 2/3] selftests: actually run the various net selftests
Date: Tue, 19 Sep 2017 14:00:57 -0600
Message-ID: <ab0e57c1-3e3d-edaa-de8f-f24b601f405f@osg.samsung.com>
References: <1505755982-7855-1-git-send-email-jbacik@fb.com>
 <1505755982-7855-2-git-send-email-jbacik@fb.com>
 <09f17145-5f0a-ec61-3dfb-69216eac7133@kernel.org>
 <20170919133424.mzshgf67al7mv3fg@destiny>
 <CAF=yD-JewUiQso6XbDEAjC+gP=yK=czsdujYmcu5=jjXTsweDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Willem de Bruijn <willemb@google.com>, Josef Bacik <jbacik@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Shuah Khan <shuah@kernel.org>,
        Shuah Khan <shuahkh@osg.samsung.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Josef Bacik <josef@toxicpanda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:38691
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751097AbdISUBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:01:02 -0400
In-Reply-To: <CAF=yD-JewUiQso6XbDEAjC+gP=yK=czsdujYmcu5=jjXTsweDA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 12:14 PM, Willem de Bruijn wrote:
> On Tue, Sep 19, 2017 at 9:34 AM, Josef Bacik <josef@toxicpanda.com> wrote:
>> On Mon, Sep 18, 2017 at 04:14:41PM -0600, Shuah Khan wrote:
>>> On 09/18/2017 11:32 AM, josef@toxicpanda.com wrote:
>>>> From: Josef Bacik <jbacik@fb.com>
>>>>
>>>> These self tests are just self contained binaries, they are not run by
>>>> any of the scripts in the directory.  This means they need to be marked
>>>> with TEST_GEN_PROGS to actually be run, not TEST_GEN_FILES.
>>>>
>>>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>>>> ---
>>>>  tools/testing/selftests/net/Makefile | 4 ++--
>>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
>>>> index 3df542c84610..45a4e77a47c4 100644
>>>> --- a/tools/testing/selftests/net/Makefile
>>>> +++ b/tools/testing/selftests/net/Makefile
>>>> @@ -6,8 +6,8 @@ CFLAGS += -I../../../../usr/include/
>>>>  TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh rtnetlink.sh
>>>>  TEST_GEN_FILES =  socket
>>>>  TEST_GEN_FILES += psock_fanout psock_tpacket
>>>> -TEST_GEN_FILES += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
>>>> -TEST_GEN_FILES += reuseport_dualstack msg_zerocopy reuseaddr_conflict
>>>> +TEST_GEN_PROGS += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
>>>> +TEST_GEN_PROGS += reuseport_dualstack msg_zerocopy reuseaddr_conflict
>>>
>>> Hmm. I see msg_zerocopy.sh for running msg_zerocopy. msg_zerocopy should
>>> still stay in TEST_GEN_FILES and msg_zerocopy.sh needs to be added to
>>> TEST_PROGS so it runs.
>>>
>>
>> Actually the shell script requires arguments, it doesn't just run the test.
>> I'll fix this to just omit the test for now as it's not setup to run properly.
>>
>> Willem, could you follow up with a patch so that the zero copy test is run
>> properly the way you envision it running?  You need to make sure that
>>
>> make -C tools/testing/selftests TARGETS=net run_tests
>>
>> actually runs your zero copy test the way you expect it to, otherwise it's just
>> sitting there collecting dust.  Thanks,
> 
> Will do.
> 
> In its current state, this test is really only meant to be run manually.
> It demonstrates the API and outputs some information on stderr.
> 
> Zerocopy itself requires a two-host test. The feature is expressly
> disabled over loopback.

Running this manually is [perfectly fine. TEST_GEN_FILES is the right
place for it as TEST_GEN_FILES will get built and installed, but won't
be run bt lib.mk. No changes needed.

> 
> But I can make this a pass/fail tests that exercises the interface
> and notification channel and verifies that data was copied. It will
> be a bit more work than just changing the default invocation of
> msg_zerocopy.sh
> 

No need to make changes as this test is intended to be run manually.
Josef's v2 doesn't change the location of msg_zerocopy. We are all set.

Thanks for clearing this up.

-- Shuah
