From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 23 Nov 2015 14:49:43 -0800
Message-ID: <CAEh+42jWN961Gg59xbdXiFj9u7=3vuFdyXkcr6iPJ92ZizPpGw@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com> <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:41327 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbbKWWuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 17:50:06 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 14F7320858
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 22:50:04 +0000 (UTC)
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5B8F020852
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 22:50:03 +0000 (UTC)
Received: by qgea14 with SMTP id a14so124275540qge.0
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 14:50:02 -0800 (PST)
In-Reply-To: <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 1:53 PM, Tom Herbert <tom@herbertland.com> wrote:
>> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
>> index cb2f89f..72415aa 100644
>> --- a/include/net/udp_tunnel.h
>> +++ b/include/net/udp_tunnel.h
>> @@ -9,6 +9,12 @@
>>  #include <net/addrconf.h>
>>  #endif
>>
>> +enum udp_tunnel_type {
>> +       UDP_TUNNEL_UNSPEC,
>> +       UDP_TUNNEL_VXLAN,
>> +       UDP_TUNNEL_GENEVE,
>> +};
>> +
>
> Sorry, I still don't like this. Grant it least it gets rid of of VXLAN
> specific ops, but the problem is there no such things as a common set
> of encapsulations in the kernel (e.g. foo-over-udp adds a bunch of
> encapsulations not represented here), no defined common set of device
> functionality that needs this, and this precludes the use of the RX
> accelerations to be available from a userpsace  implementation.

Regardless, I think this is at least a good cleanup of what is already
there compared to having VXLAN-specific NDOs. We can always add
additional things in the future.
