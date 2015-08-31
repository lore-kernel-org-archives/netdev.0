From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next] lib: move strncpy_from_unsafe() into mm/maccess.c
Date: Mon, 31 Aug 2015 12:43:22 -0700
Message-ID: <55E4AE5A.7010003@roeck-us.net>
References: <1441036630-10124-1-git-send-email-ast@plumgrid.com> <20150831.123628.1591879942458458246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, rostedt@goodmis.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:48029 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbbHaTnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:43:25 -0400
In-Reply-To: <20150831.123628.1591879942458458246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2015 12:36 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Mon, 31 Aug 2015 08:57:10 -0700
>
>> To fix build errors:
>> kernel/built-in.o: In function `bpf_trace_printk':
>> bpf_trace.c:(.text+0x11a254): undefined reference to `strncpy_from_unsafe'
>> kernel/built-in.o: In function `fetch_memory_string':
>> trace_kprobe.c:(.text+0x11acf8): undefined reference to `strncpy_from_unsafe'
>>
>> move strncpy_from_unsafe() next to probe_kernel_read/write()
>> which use the same memory access style.
>>
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Reported-by: Guenter Roeck <linux@roeck-us.net>

Too late, but:

Tested-by: Guenter Roeck <linux@roeck-us.net>

Guenter

>> Fixes: 1a6877b9c0c2 ("lib: introduce strncpy_from_unsafe()")
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>> For configs without kprobes and bpf the cost of this unused function is
>> ~200 bytes which I think is a better trade off vs creating
>> new Kconfig selector just for this single function.
>> Another alternative is to move it to kernel/trace/trace_kprobe.c,
>> but then it will lose generality and probably should be removed
>> from include/linux/uaccess.h, so mm/maccess.c looks the best.
>
> Ok, applied.
>
