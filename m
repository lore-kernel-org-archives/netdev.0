From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 6/9] mlxsw: spectrum: Unmap local port from module
 during teardown
Date: Mon, 22 Feb 2016 13:08:37 -0800
Message-ID: <56CB78D5.2070308@gmail.com>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us> <1456165924-14399-7-git-send-email-jiri@resnulli.us> <56CB706F.3000301@gmail.com> <20160222210054.GA7745@colbert.idosch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, yishaih@mellanox.com, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	eugenia@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33097 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbcBVVJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 16:09:20 -0500
Received: by mail-pf0-f182.google.com with SMTP id q63so98695977pfb.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 13:09:19 -0800 (PST)
In-Reply-To: <20160222210054.GA7745@colbert.idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-22 01:00 PM, Ido Schimmel wrote:
> Hi John,
> 
> Mon, Feb 22, 2016 at 10:32:47PM IST, john.fastabend@gmail.com wrote:
>> On 16-02-22 10:32 AM, Jiri Pirko wrote:
>>> From: Ido Schimmel <idosch@mellanox.com>
>>>
>>> When splitting a port we replace it with 2 or 4 other ports. To be able
>>> to do that we need to remove the original port netdev and unmap it from
>>> its module. However, we first mark it as disabled, as active ports
>>> cannot be unmapped.
>>>
>>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>
>> Hi Jiri, Ido,
>>
>> You've sort of lost me on this port splitting/unsplitting thread. What
>> does this actually do? Are you just creating two netdevs and LAGing them
>> in the hardware, I'm guessing not or you wouldn't have some device API
>> for it and would do it using normal methods.
> 
> Yep, it's not LAG. You basically have a mapping between a physical
> module and a local port, which is represented by a port netdev.
> 
> Each module has 4 lanes, so if you connect a splitter (say a 2x) you can
> map each 2 lanes to a different port and assign each a new local port.
> These are completely independent from each other, but they can only give
> you 50Gb/s max, as opposed to the original 100Gb/s (as it had 4 lanes
> all to itself).
> 
>>
>> If its something to do with physical layout of the board itself why
>> don't you trigger this based on some init time introspection or an
>> interrupt if someone plugs in a port splitting cable/module (does that
>> exist?).
> 
> We currently don't have an event that tells us that a splitter is
> connected. Also, had we created / destroyed these based on events, then
> an accidental removal of the splitter would cause all the configuration
> setup on these ports to disappear (say VLANs on a bridged port, unicast
> flooding etc.).
> 

I still think this would be the better implementation. The configuration
should be saved in some daemon anyways and setup based on netdev events
so its not like it would disappear in any real system.

But seeing you don't get an interrupt or anything I guess manual
configuration is going to be the best you can do.


> Thanks.
> 
>>
>> Thanks,
>> John
>>
>>
