From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Regarding group_forward_mask in bridge in 3.4 kernel
Date: Mon, 17 Sep 2012 08:24:49 -0700
Message-ID: <505740C1.9080706@intel.com>
References: <CADAe=++yAm3t-ZqMKy9h-Rda5=pOYQD2-cKUd3S1VKmBZQfT9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21948 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756793Ab2IQPYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 11:24:50 -0400
In-Reply-To: <CADAe=++yAm3t-ZqMKy9h-Rda5=pOYQD2-cKUd3S1VKmBZQfT9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/17/2012 7:43 AM, Ajith Adapa wrote:
> Hi,
>
> I am trying to enable group_fwd_mask in bridge by giving the below
> command so that it can forward provider bpdu's whose destination
> address is 01-80-C2-00-00-08.
>
> echo 8 > /sys/class/net/vpc1_br/bridge/group_fwd_mask
>

wrong value see the logic you quoted use 1 << 8

echo 256 > /sys/class/net/...

Your example fwds non-TPMR addresses 01-80-c2-00-00-03.

[...]

> Am I giving wrong value for group_fwd_mask ??

Yep wrong value.

> I tried other values but seems only 8 and 0 is accepted.

The logic makes an attempt to restrict forwarding by masking 0x4007u,
catching many known control protocols.

See commit for details,

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=515853ccecc6987dfb8ed809dd8bf8900286f29e

.John
