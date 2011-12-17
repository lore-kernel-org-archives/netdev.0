From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 0/13] Dumping AF_UNIX sockets via netlink
Date: Sat, 17 Dec 2011 13:54:10 +0400
Message-ID: <4EEC66C2.50209@parallels.com>
References: <4EE9EB2A.4040909@parallels.com> <20111216.135024.262929657289610510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9469 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125Ab1LQJyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Dec 2011 04:54:19 -0500
In-Reply-To: <20111216.135024.262929657289610510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2011 10:50 PM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Thu, 15 Dec 2011 16:42:18 +0400
> 
>> Make the unix_diag.ko module, which is the AF_UNIX client for the sock_diag.
>>
>> Use the sock_i_ino() as the primary ID key for sockets. This is currently the
>> only unique (except for the sk address itself) ID of a unix socket and is de
>> facto used in the ss tool to identify sockets. Thus the basic nlk request and
>> response structures operate on this ID. Other socket info (sun_name, peer, etc.)
>> are reported in the respective NLA-s (patches 8 through 12).
>>
>> There's a locking trickery in patch #11. I've tried to study it carefully and
>> checked with lockdep, but anyway, please, pay special attention to it.
>>
>> The patch for ss tool is also included.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> Looks good, applied.
> 
> I'm slightly confused by the module alias strings these diag modules
> are using, can you explain it to me?
> 
> On one side it looks like it wants to see a suffix of "-${AF_INET}-${IPPROTO_TCP}"
> but in the macros you pass in one numerical value, which is AF_INET minus the
> protocol value.

You're right, the intention is to get the "family-protocol" pair, and the minus you
see (surrounded with numbers) is put into the stringify macro, which works like

  stringify(2-16) => "2-16"

since (as far as I understand this) C pre-processor doesn't perform arithmetic 
calculations.

> How does that work?
> 
> Thanks.
> .
> 

Thanks,
Pavel
