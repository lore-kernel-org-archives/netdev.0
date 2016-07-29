From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Fri, 29 Jul 2016 09:54:07 +0200
Message-ID: <579B0B9F.8040805@iogearbox.net>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com> <20160729064722.GA54517@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41146 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbcG2HyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 03:54:09 -0400
In-Reply-To: <20160729064722.GA54517@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/2016 08:47 AM, Alexei Starovoitov wrote:
> On Thu, Jul 28, 2016 at 05:42:21PM -0700, William Tu wrote:
>> The total size of value copy_to_user() writes to userspace should
>> be the (current number of cpu) * (value size), instead of
>> num_possible_cpus() * (value size).  Found by samples/bpf/test_maps.c,
>> which always copies 512 byte to userspace, crashing the userspace
>> program stack.
>
> hmm. I'm missing something. The sample code assumes no cpu hutplug,
> so sysconf(_SC_NPROCESSORS_CONF) == num_possible_cpu == num_online_cpu,
> unless there is crazy INIT_ALL_POSSIBLE config option is used.

Are you using ARM by chance? What is the count that you get in
user space and from kernel side?

http://lists.infradead.org/pipermail/linux-arm-kernel/2011-June/054177.html
