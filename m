From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH] bpf: avoid warning for wrong pointer cast
Date: Tue, 19 Apr 2016 09:27:28 -0700
Message-ID: <57165C70.80209@fb.com>
References: <1460838585-1248139-1-git-send-email-arnd@arndb.de>
 <20160417004740.GA80675@ast-mbp.thefacebook.com>
 <20160419023334.GC24067@wfg-t540p.sh.intel.com>
 <20160419100956.GB8836@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<linux-kernel@vger.kernel.org>
To: Philip Li <philip.li@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160419100956.GB8836@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/19/16 3:09 AM, Philip Li wrote:
> On Tue, Apr 19, 2016 at 10:33:34AM +0800, Fengguang Wu wrote:
>>> Fengguang, any idea why build-bot sometimes silent?
>>
>> Sorry I went off for some time.. Philip, would you help have a check?
> Hi Alexei, i have done some investigation for this. Fengguang, pls correct me if my understanding is wrong.
>
> 0day has caught the warning for f1ff54 commit around 2016-3-22, which considers the same warning in future is not new one, thus neglect it.
>
> 	rli9@inn /kbuild-tests/build-error$ cat kernel-trace-bpf_trace.c:warning:cast-to-pointer-from-integer-of-different-size
> 	kernel/trace/bpf_trace.c:345:13: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>
> 	2016-03-22 17:12:38 xian bpf:master:321e70e79c94e5e6394a882d567baac949b74000 i386-randconfig-x009-201612 f1ff543dbdd3eff53c8328cfb582f18e6c3d56ec
>
> And for f1ff54's warning, 0day actually bisects to it, but then it checks the head of bpf/master at that time which is 321e70e, find the error is not existed, so
> it ignores the interim warning to not send email report.
>
> 2016-03-22_17:15:49 O: R: /kbuild/src/consumer/kernel/trace/bpf_trace.c:345:13: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
> 2016-03-22_17:15:49 O: grep -h -r . /tmp/kernel/i386-randconfig-x009-201612/gcc-5/f1ff543dbdd3eff53c8328cfb582f18e6c3d56ec/build-error # 0 errors
> 2016-03-22_17:15:49 O: grep -h -r . /tmp/kernel/i386-randconfig-x009-201612/gcc-5/f1ff543dbdd3eff53c8328cfb582f18e6c3d56ec/build-error/ # 0 errors
> 2016-03-22_17:15:49 O: /c/kernel-tests/list-head bpf:master:321e70e79c94e5e6394a882d567baac949b74000 i386-randconfig-x009-201612
> 2016-03-22_17:16:03 O: .
> 2016-03-22_17:16:03 O: ..
> 2016-03-22_17:16:03 O: kernel-trace-bpf_trace.c:warning:cast-to-pointer-from-integer-of-different-size
> 2016-03-22_17:16:03 O: 2016-03-22 17:16:03 don't email interim warnings
> 2016-03-22_17:16:03 O: 2016-03-22 17:16:03 error no longer exist in head bpf/master 321e70e79c94e5e6394a882d567baac949b74000, check
> /tmp/kernel/i386-randconfig-x009-201612/gcc-5/321e70e79c94e5e6394a882d567baac949b74000, errno 14
> 2016-03-22_17:16:03 O: 2016-03-22 17:16:03 Don't email interim warnings!
>
>
> what really happens to 321e70e is it has build error (i rerun it to confirm), which is reported. So this is
> a possible change to be done in 0day to report the first bad commit when HEAD is build error.

excellent sleuthing! Sounds like the adjustment to 0day is forthcoming.
Thank you for great tool!
