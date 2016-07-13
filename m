From: Fengguang Wu <lkp@intel.com>
Subject: Re: [PATCH net-next 3/3] bpf: avoid stack copy and use skb ctx for
 event output
Date: Wed, 13 Jul 2016 08:01:55 +0800
Message-ID: <20160713000155.GA20432@wfg-t540p.sh.intel.com>
References: <201607130750.HlB4VMOA%fengguang.wu@intel.com>
 <5785812B.4080505@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: kbuild-all@01.org, davem@davemloft.net,
	alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5785812B.4080505@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Wed, Jul 13, 2016 at 01:45:47AM +0200, Daniel Borkmann wrote:
>On 07/13/2016 01:25 AM, kbuild test robot wrote:
>> Hi,
>>
>> [auto build test WARNING on net-next/master]
>>
>> url:    https://github.com/0day-ci/linux/commits/Daniel-Borkmann/BPF-event-output-helper-improvements/20160713-065944
>> config: s390-allyesconfig (attached as .config)
>> compiler: s390x-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
>> reproduce:
>>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>          chmod +x ~/bin/make.cross
>>          # save the attached .config to linux build tree
>>          make.cross ARCH=s390
>>
>> All warnings (new ones prefixed by >>):
>>
>>     kernel/trace/bpf_trace.c: In function 'bpf_perf_event_output':
>>     kernel/trace/bpf_trace.c:284:1: warning: 'bpf_perf_event_output' uses dynamic stack allocation
>>      }
>>      ^
>>     kernel/trace/bpf_trace.c: In function 'bpf_event_output':
>>>> kernel/trace/bpf_trace.c:319:1: warning: 'bpf_event_output' uses dynamic stack allocation
>>      }
>>      ^
>
>Hmm, searching a bit on lkml, it seems these warnings on s390 are actually mostly
>harmless I believe [1][2] ... looks like they are there to find structs sitting
>on stack, for example, at least that's also what the currently existing one in the
>above line (bpf_trace.c +284) appears to be about.

Yes it does look so. All such warnings happen only in s390:

% g -h -o '[^ ]*config' *dynamic-stack* | sort | uniq -c | sort -nr
    118 s390-allyesconfig
     80 s390-allmodconfig

Let's ignore all of them on s390.

Thanks,
Fengguang

>   [1] http://lkml.iu.edu/hypermail/linux/kernel/1601.2/04074.html
>   [2] https://lkml.org/lkml/2013/6/25/42
