From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if
 available
Date: Tue, 10 Dec 2013 21:47:48 +0100
Message-ID: <52A77DF4.5070302@redhat.com>
References: <1386669178-14450-1-git-send-email-ffusco@redhat.com>	<CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com> <20131210.143652.1279430126319061689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ffusco@redhat.com, netdev@vger.kernel.org, dev@openvswitch.org,
	dborkman@redhat.com
To: David Miller <davem@davemloft.net>, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768Ab3LJUsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 15:48:21 -0500
In-Reply-To: <20131210.143652.1279430126319061689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2013 08:36 PM, David Miller wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Tue, 10 Dec 2013 11:28:08 -0800
>
>> I think this is definitely a good optimization to do given that so
>> much of the work that OVS does is hashing. However, isn't there a
>> library where there would be a more appropriate place to put this?
>
> I also honestly don't see why we want to special case OVS at all
> here.  This faster hashing would be useful for socket demux and
> other locations in the kernel.
>
> When I see changes like this my only reaction is "sad face".

We discussed this heavily and decided to go with the minimal approach
first to collect some feedback. We were not sure whether the runtime
check, function pointer and hardware dependencies are something other
subsystems that are less x86_64 centric would want to live with.

That said, we are _very_ willing to do the work and move it to lib/
to make it available to other consumers but one should be aware that
crc32 based hashes are not as generally usable as jhash.
