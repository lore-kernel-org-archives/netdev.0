From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH v2 11/19] selftests/memory-hotplug: add install target
 to enable installing test
Date: Mon, 01 Dec 2014 09:12:23 -0700
Message-ID: <547C9367.2070804@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com> <8cdb2abb6eaa794801548e04ee6b9f403778e126.1415735831.git.shuahkh@osg.samsung.com> <5476BB87.6010808@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	Shuah Khan <shuahkh@osg.samsung.com>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:38695 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120AbaLAQMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2014 11:12:49 -0500
In-Reply-To: <5476BB87.6010808@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 10:49 PM, Masami Hiramatsu wrote:
> (2014/11/12 5:27), Shuah Khan wrote:
>> Add a new make target to enable installing test. This target
>> installs test in the kselftest install location and add to the
>> kselftest script to run the test. Install target can be run
>> only from top level source dir.
>>
>> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
>> ---
>>  tools/testing/selftests/memory-hotplug/Makefile    |  17 +-
>>  .../selftests/memory-hotplug/mem-on-off-test.sh    | 238 +++++++++++++++++++++
>>  .../selftests/memory-hotplug/on-off-test.sh        | 238 ---------------------
>>  3 files changed, 253 insertions(+), 240 deletions(-)
>>  create mode 100644 tools/testing/selftests/memory-hotplug/mem-on-off-test.sh
>>  delete mode 100644 tools/testing/selftests/memory-hotplug/on-off-test.sh
>>
>> diff --git a/tools/testing/selftests/memory-hotplug/Makefile b/tools/testing/selftests/memory-hotplug/Makefile
>> index d46b8d4..8921631 100644
>> --- a/tools/testing/selftests/memory-hotplug/Makefile
>> +++ b/tools/testing/selftests/memory-hotplug/Makefile
>> @@ -1,9 +1,22 @@
>> +TEST_STR=/bin/bash ./mem-on-off-test.sh -r 2 || echo memory-hotplug selftests: [FAIL]
>> +
>>  all:
>>  
>> +install:
>> +ifdef INSTALL_KSFT_PATH
>> +	install ./mem-on-off-test.sh $(INSTALL_KSFT_PATH)/mem-on-off-test.sh
>> +	@echo echo Start memory hotplug test .... >> $(KSELFTEST)
>> +	@echo "$(TEST_STR)" >> $(KSELFTEST) >> $(KSELFTEST)
>> +	@echo echo End memory hotplug test .... >> $(KSELFTEST)
>> +	@echo echo ============================== >> $(KSELFTEST)
>> +else
>> +	@echo Run make kselftest_install in top level source directory
>> +endif
> 
> I saw this pattern repeated many times in this series.
> Can we make it a macro and include it instead of repeating this code?
> 

I might be able to move this to the selftest Makfile and use target as the
string. I will play with it and see if I can reduce the duplication further.

thanks,
-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
