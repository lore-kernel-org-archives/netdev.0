From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC V2 PATCH 00/25] Kernel NET policy
Date: Thu, 4 Aug 2016 18:31:40 -0700
Message-ID: <20160805013138.GA52225@ast-mbp.thefacebook.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33820 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964818AbcHEBbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 21:31:47 -0400
Content-Disposition: inline
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 08:38:49PM -0500, kan.liang@intel.com wrote:
> 
> Changes since V1:
>  - Using work queue to set Rx network flow classification rules and search
>    available NET policy object asynchronously.
>  - Using RCU lock to replace read-write lock
>  - Redo performance test and update performance results.
>  - Some minor modification for codes and documents.
>  - Remove i40e related patches which will be submitted in separate thread.

Most of the issues brought up in the prior submission were not addressed,
so one more NACK from me as well.
My objection with this approach is the same as others:
such policy doesn't belong in the kernel.

>  1. Why userspace tool cannot do the same thing?
>     A: Kernel is more suitable for NET policy.
>        - User space code would be far more complicated to get right and perform
>          well . It always need to work with out of date state compared to the
>          latest, because it cannot do any locking with the kernel state.
>        - User space code is less efficient than kernel code, because of the
>          additional context switches needed.
>        - Kernel is in the right position to coordinate requests from multiple
>          users.

and above excuses is the reason to hack flow director rules in the kernel?
You can do the same in user space. It's not a kernel job.
