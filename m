From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 6/9] mlxsw: spectrum: Unmap local port from
 module during teardown
Date: Mon, 22 Feb 2016 23:00:54 +0200
Message-ID: <20160222210054.GA7745@colbert.idosch.org>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-7-git-send-email-jiri@resnulli.us>
 <56CB706F.3000301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <eladr@mellanox.com>, <yotamg@mellanox.com>,
	<ogerlitz@mellanox.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <eugenia@mellanox.com>,
	<roopa@cumulusnetworks.com>, <nikolay@cumulusnetworks.com>,
	<hadarh@mellanox.com>, <jhs@mojatatu.com>,
	<jeffrey.t.kirsher@intel.com>, <brouer@redhat.com>,
	<ivecera@redhat.com>, <rami.rosen@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0083.outbound.protection.outlook.com ([157.55.234.83]:27712
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751937AbcBVVQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 16:16:12 -0500
Content-Disposition: inline
In-Reply-To: <56CB706F.3000301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

Mon, Feb 22, 2016 at 10:32:47PM IST, john.fastabend@gmail.com wrote:
>On 16-02-22 10:32 AM, Jiri Pirko wrote:
>> From: Ido Schimmel <idosch@mellanox.com>
>> 
>> When splitting a port we replace it with 2 or 4 other ports. To be able
>> to do that we need to remove the original port netdev and unmap it from
>> its module. However, we first mark it as disabled, as active ports
>> cannot be unmapped.
>> 
>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>
>Hi Jiri, Ido,
>
>You've sort of lost me on this port splitting/unsplitting thread. What
>does this actually do? Are you just creating two netdevs and LAGing them
>in the hardware, I'm guessing not or you wouldn't have some device API
>for it and would do it using normal methods.

Yep, it's not LAG. You basically have a mapping between a physical
module and a local port, which is represented by a port netdev.

Each module has 4 lanes, so if you connect a splitter (say a 2x) you can
map each 2 lanes to a different port and assign each a new local port.
These are completely independent from each other, but they can only give
you 50Gb/s max, as opposed to the original 100Gb/s (as it had 4 lanes
all to itself).

>
>If its something to do with physical layout of the board itself why
>don't you trigger this based on some init time introspection or an
>interrupt if someone plugs in a port splitting cable/module (does that
>exist?).

We currently don't have an event that tells us that a splitter is
connected. Also, had we created / destroyed these based on events, then
an accidental removal of the splitter would cause all the configuration
setup on these ports to disappear (say VLANs on a bridged port, unicast
flooding etc.).

Thanks.

>
>Thanks,
>John
>
>
