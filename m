From: Hanjun Guo <guohanjun@huawei.com>
Subject: Re: [PATCH net] net:sysctl fix the confusing corner of tcp_mem
Date: Mon, 21 Dec 2015 09:02:20 +0800
Message-ID: <56774F9C.4070303@huawei.com>
References: <1449626509-3736-1-git-send-email-wangyufen@huawei.com> <877fknbms6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<zhangdianfang@huawei.com>, <dingtianhong@huawei.com>,
	<huxinwei@huawei.com>, Eric Dumazet <eric.dumazet@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Wang Yufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:62735 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbbLUBCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 20:02:39 -0500
In-Reply-To: <877fknbms6.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 2015/12/10 0:38, Eric W. Biederman wrote:
> Wang Yufen <wangyufen@huawei.com> writes:
>
>> From: Yufen Wang <wangyufen@huawei.com>
>>
>> I tried on linux-4.1:
>>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>>     8388608	12582912	16777216
>>     linux:~# echo 1234 >/proc/sys/net/ipv4/tcp_mem 
>>     -bash: echo: write error: Invalid argument
>>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>>     1234	12582912	16777216
>>
>> the echo operation got error, but value already written to tcp_mem.
>> If a write() returns an error like EINVAL, we expect no change occurred.
>> This patch fix the confusing corner and makes __do_proc_doulongvec_minmax 
>> works the same as __do_proc_dointvec
> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Except for possibly breaking your muscle memory this does not explain
> why this is a problem.

I think it's really confusing that we got write error but actually the
value echoed is written properly, at least we need to fix it and make
the result match the behavior, right?

>
> Further you are changing a whole lot more than tcp_mem, without a word
> of justification in your description.

I agree, we can update the change log.

Thanks
Hanjun
