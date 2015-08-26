From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics
 via debugfs
Date: Wed, 26 Aug 2015 09:37:57 +0200
Message-ID: <20150826073757.GB2215@nanopsycho.orion>
References: <1440427547-8539-3-git-send-email-jiri@resnulli.us>
 <20150825.142521.1764936130530564868.davem@davemloft.net>
 <20150826055215.GA2215@nanopsycho.orion>
 <20150825.230821.2162893312002303587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33690 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474AbbHZHiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 03:38:00 -0400
Received: by wijn1 with SMTP id n1so14874377wij.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 00:37:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150825.230821.2162893312002303587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 26, 2015 at 08:08:21AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 26 Aug 2015 07:52:15 +0200
>
>> They are simple statistics. But they does not fit into any existing
>> interface. This is about EMAD packets. They are not per-netdevice, but
>> per-pcidevice. So I cannot put them into ethtool.
>> 
>> I see no other iface to expose this other than debugfs. Please suggest
>> some other way, I don't see it :/
>
>Then create one, instead of crapping up the driver with debugfs
>craziness.

I'm not sure it is possible to come up with a generic interface for
arbitraty statistics for some generic PCI device.

I can imagine the pushback saying "hey, put that statistics into subtree
specific area, like netdev etc". And that is correct. In vast majority
of cases, that can be done.

In mlxsw case however, 36 netdevices are sharing 1 pci device. And the
stuff related to that pci device cannot be exposed via netdev.

I don't think that are much more cases like this. Therefore I think that
for this cases, debugfs might be a good way to expose debugging stats.


>
>>>I'm not applying this, and I'm really getting irritated about how much
>>>garbage people put into debugfs when it has _NO_ business being there.
>> 
>> I think that is the primary purpose of this iface, To put arbitrary
>> debugging garbage there. Am I missing something?
>
>It's not garbage if it's useful for someone.
>
>If it's not useful, why even bother?
>
>This is why I hate debugfs, it's a fundamentally flawed facility.
