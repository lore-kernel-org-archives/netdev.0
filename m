From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH v2 02/19] kbuild: kselftest_install - add a new make target
 to install selftests
Date: Mon, 01 Dec 2014 09:27:40 -0700
Message-ID: <547C96FC.6020100@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com> <a2344d4df903d673afe1631118f40917f773cc9a.1415735831.git.shuahkh@osg.samsung.com> <5476B763.1030701@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5476B763.1030701@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2014 10:32 PM, Masami Hiramatsu wrote:
> (2014/11/12 5:27), Shuah Khan wrote:
>> Add a new make target to install to install kernel selftests.
>> This new target will build and install selftests. kselftest
>> target now depends on kselftest_install and runs the generated
>> kselftest script to reduce duplicate work and for common look
>> and feel when running tests.
>>
>> Approach:
>>
>> make kselftest_target:
> 
> kselftest_install?

Thanks for catching this. Will fix it.

> 
>> -- exports kselftest INSTALL_KSFT_PATH
>>    default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
>> -- exports path for ksefltest.sh
>> -- runs selftests make install target:
> 
> This direction is OK to me.
> 
> BTW, I've found another path to make selftest in Makefile,
> Actually you can do
> 
> make -C tools/ selftest
> 
> And there are selftest_install and selftest_clean targets (but
> currently it has a bug and doesn't work, anyway)

Thanks for pointing this out. I didn't know this existed. kind of
hidden.

> 
> I think we'd better do subdir make instead of adding these targets.
> This means that "make kselftest*" should be an alias of "make -C tools/ selftest*"
> 

Yes that would be a good way to go and helps leverage these options
at tools/Makefile level.

> Also, I'd like to request passing some options like as O=$(objtree)
> so that we can make test kmodules in selftests.

Sounds good. I will look into it.

thanks,
-- Shuah

-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
