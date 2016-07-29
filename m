From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Thu, 28 Jul 2016 23:47:24 -0700
Message-ID: <20160729064722.GA54517@ast-mbp.thefacebook.com>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36097 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcG2Gra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 02:47:30 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so4718350pab.3
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 23:47:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2016 at 05:42:21PM -0700, William Tu wrote:
> The total size of value copy_to_user() writes to userspace should
> be the (current number of cpu) * (value size), instead of
> num_possible_cpus() * (value size).  Found by samples/bpf/test_maps.c,
> which always copies 512 byte to userspace, crashing the userspace
> program stack.

hmm. I'm missing something. The sample code assumes no cpu hutplug,
so sysconf(_SC_NPROCESSORS_CONF) == num_possible_cpu == num_online_cpu,
unless there is crazy INIT_ALL_POSSIBLE config option is used.
