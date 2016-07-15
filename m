From: Topi Miettinen <toiwoton@gmail.com>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
Date: Fri, 15 Jul 2016 16:35:33 +0000
Message-ID: <41b6ca51-1358-0fd7-b45a-dc29a1344865@gmail.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <20160715130458.GB21685@350D>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
 Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>,
 Hal Rosenstock <hal.rosenstock@gmail.com>,
 Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>,
 Sudeep Dutt <sudeep.dutt@intel.com>,
 Ashu
To: bsingharora@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160715130458.GB21685@350D>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 07/15/16 13:04, Balbir Singh wrote:
> On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
>> Hello,
>>
>> There are many basic ways to control processes, including capabilities,
>> cgroups and resource limits. However, there are far fewer ways to find out
>> useful values for the limits, except blind trial and error.
>>
>> This patch series attempts to fix that by giving at least a nice starting
>> point from the highwater mark values of the resources in question.
>> I looked where each limit is checked and added a call to update the mark
>> nearby.
>>
>> Example run of program from Documentation/accounting/getdelauys.c:
>>
>> ./getdelays -R -p `pidof smartd`
>> printing resource accounting
>> RLIMIT_CPU=0
>> RLIMIT_FSIZE=0
>> RLIMIT_DATA=18198528
>> RLIMIT_STACK=135168
>> RLIMIT_CORE=0
>> RLIMIT_RSS=0
>> RLIMIT_NPROC=1
>> RLIMIT_NOFILE=55
>> RLIMIT_MEMLOCK=0
>> RLIMIT_AS=130879488
>> RLIMIT_LOCKS=0
>> RLIMIT_SIGPENDING=0
>> RLIMIT_MSGQUEUE=0
>> RLIMIT_NICE=0
>> RLIMIT_RTPRIO=0
>> RLIMIT_RTTIME=0
>>
>> ./getdelays -R -C /sys/fs/cgroup/systemd/system.slice/smartd.service/
>> printing resource accounting
>> sleeping 1, blocked 0, running 0, stopped 0, uninterruptible 0
>> RLIMIT_CPU=0
>> RLIMIT_FSIZE=0
>> RLIMIT_DATA=18198528
>> RLIMIT_STACK=135168
>> RLIMIT_CORE=0
>> RLIMIT_RSS=0
>> RLIMIT_NPROC=1
>> RLIMIT_NOFILE=55
>> RLIMIT_MEMLOCK=0
>> RLIMIT_AS=130879488
>> RLIMIT_LOCKS=0
>> RLIMIT_SIGPENDING=0
>> RLIMIT_MSGQUEUE=0
>> RLIMIT_NICE=0
>> RLIMIT_RTPRIO=0
>> RLIMIT_RTTIME=0
> 
> Does this mean that rlimit_data and rlimit_stack should be set to the
> values as specified by the data above?

My plan is that either system administrator, distro maintainer or even
upstream developer can get reasonable values for the limits. They may
still be wrong, but things would be better than without any help to
configure the system.

> 
> Do we expect a smart user space daemon to then tweak the RLIMIT values?

Someone could write an autotuning daemon that checks if the system has
changed (for example due to upgrade) and then run some tests to
reconfigure the system. But the limits are a bit too fragile, or rather,
applications can't handle failure, so I don't know if that would really
work.

-Topi


> 
> Balbir Singh.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
