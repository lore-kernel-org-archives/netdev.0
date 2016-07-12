From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/3] bpf: avoid stack copy and use skb ctx for
 event output
Date: Wed, 13 Jul 2016 01:45:47 +0200
Message-ID: <5785812B.4080505@iogearbox.net>
References: <201607130750.HlB4VMOA%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net,
	alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49194 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcGLXqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 19:46:18 -0400
In-Reply-To: <201607130750.HlB4VMOA%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2016 01:25 AM, kbuild test robot wrote:
> Hi,
>
> [auto build test WARNING on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Daniel-Borkmann/BPF-event-output-helper-improvements/20160713-065944
> config: s390-allyesconfig (attached as .config)
> compiler: s390x-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=s390
>
> All warnings (new ones prefixed by >>):
>
>     kernel/trace/bpf_trace.c: In function 'bpf_perf_event_output':
>     kernel/trace/bpf_trace.c:284:1: warning: 'bpf_perf_event_output' uses dynamic stack allocation
>      }
>      ^
>     kernel/trace/bpf_trace.c: In function 'bpf_event_output':
>>> kernel/trace/bpf_trace.c:319:1: warning: 'bpf_event_output' uses dynamic stack allocation
>      }
>      ^

Hmm, searching a bit on lkml, it seems these warnings on s390 are actually mostly
harmless I believe [1][2] ... looks like they are there to find structs sitting
on stack, for example, at least that's also what the currently existing one in the
above line (bpf_trace.c +284) appears to be about.

Thanks,
Daniel

   [1] http://lkml.iu.edu/hypermail/linux/kernel/1601.2/04074.html
   [2] https://lkml.org/lkml/2013/6/25/42
