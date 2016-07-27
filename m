From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 27 Jul 2016 16:45:43 -0700 (PDT)
Message-ID: <20160727.164543.1466564919313003461.davem@davemloft.net>
References: <201607271032.u6RAWPcS008174@sdf.org>
	<4dbfebe8136bc963b5b51463d6887db4@triadic.us>
	<87c4ed555bcb4229f2334f6f2bb69bcb@triadic.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rlwinm@sdf.org, viro@zeniv.linux.org.uk, chunkeey@googlemail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alexmcwhirter@triadic.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932335AbcG0Xpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 19:45:47 -0400
In-Reply-To: <87c4ed555bcb4229f2334f6f2bb69bcb@triadic.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alexmcwhirter@triadic.us
Date: Wed, 27 Jul 2016 19:02:40 -0400

> On 2016-07-27 14:04, alexmcwhirter@triadic.us wrote:
>> Just to add some more information to this, the corruption seems to
>> effect ssh as well.
>> Using a sun hme interface, occasionally upon an ssh connection it will
>> refuse to authenticate a client with either password or cert
>> authentication. Using wireshark to capture and decrypt the packets
>> between the two machines, the data coming from the server seems good,
>> but the data received by the server from the client is essentially
>> garbage. Note that the client is sending valid data, but the server is
>> corrupting it upon receipt. Closing the connection and starting a new
>> one will remedy the login issue, but you do occasionally see
>> corruption on the server side sporadically.
>> So far this only seems to occur on incoming data, outgoing data seems
>> fine.
> 
> Also, there is another patch the references this commit on sparc64 at
> least.
> 
> https://patchwork.kernel.org/patch/9221895/
> 
> I highly expect both my issue and OP's issue to revolve not around
> commit e5a4b0bb803b specifically, but around other code that no longer
> behaves as expected because of it.

Indeed, and that fault address rounding bug occurs two other times
in arch/sparc/lib/user_fixup.c

The mentioned patchwork patch should fix the bug and I'll get that
into my sparc tree, merged, and queued up for -stable ASAP.
