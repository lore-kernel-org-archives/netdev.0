From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Thu, 13 Jul 2017 11:21:04 -0700 (PDT)
Message-ID: <20170713.112104.758301784190532188.davem@davemloft.net>
References: <20170713131430.7032b5fa@redhat.com>
        <20170713181644.2d421e4d@redhat.com>
        <5967A71F.9010409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com, alexander.duyck@gmail.com,
        bjorn.topel@intel.com, jakub.kicinski@netronome.com,
        ecree@solarflare.com, sgoutham@cavium.com, Yuval.Mintz@cavium.com,
        saeedm@mellanox.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752659AbdGMSVW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 14:21:22 -0400
In-Reply-To: <5967A71F.9010409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Thu, 13 Jul 2017 10:00:15 -0700

> On 07/13/2017 09:16 AM, Jesper Dangaard Brouer wrote:
>> On Thu, 13 Jul 2017 13:14:30 +0200
>> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>> 
>>> I'm still getting crashes (but much harder to provoke), but I figured
>>> out why.  We sort of missed one case, where map_to_flush gets set, when
>>> the ndo_xdp_xmit() call starts to fail, and the ixgbe driver then
>>> forgets to call xdp_do_flush_map, if all packets in that NAPI cycle
>>> failed.  We could blame the driver, but yhe clean solution is making
>>> sure, that we don't set map_to_flush when the __bpf_tx_xdp() call
>>> fails. It should also handle the other case I fixed .... I'll cleanup
>>> my PoC-fix patch, test it and provide it here.
>> 
>> I changed flow in the function to be:
> 
> 
> Great, I'll merge this, the other couple fixes, and the bitops optimization and
> hopefully then we are set. I'll post a v2 and we can do some final checks.

I am so looking forward to merging this, great work everyone.
