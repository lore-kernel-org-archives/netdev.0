From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC net-next] net: dsa: Provide CPU port statistics to
 master netdev
Date: Tue, 26 Apr 2016 12:44:50 -0700
Message-ID: <571FC532.4060402@gmail.com>
References: <1461175101-13506-1-git-send-email-f.fainelli@gmail.com>
 <20160425214342.GB5538@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34291 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbcDZTrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 15:47:08 -0400
Received: by mail-pa0-f43.google.com with SMTP id r5so10412460pag.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 12:47:08 -0700 (PDT)
In-Reply-To: <20160425214342.GB5538@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/16 14:43, Andrew Lunn wrote:
> On Wed, Apr 20, 2016 at 10:58:21AM -0700, Florian Fainelli wrote:
>> This patch overloads the DSA master netdev, aka CPU Ethernet MAC to also
>> include switch-side statistics, which is useful for debugging purposes,
>> when the switch is not properly connected to the Ethernet MAC (duplex
>> mismatch, (RG)MII electrical issues etc.).
>>
>> We accomplish this by retaining the original copy of the master netdev's
>> ethtool_ops, and just overload the 3 operations we care about:
>> get_sset_count, get_strings and get_ethtool_stats so as to intercept
>> these calls and call into the original master_netdev ethtool_ops, plus
>> our own.
> 
> Hi Florian
> 
> Interesting concept. My one concern is that by concatenating the two
> sets of statistics, we get a name clash. I'm not sure the Marvell
> switch statistics counters have different names to the Marvell
> Ethernet driver statistics counters. ethtool does not care, but maybe
> an SNMP agent using these statistics might not be too happy seeing the
> same name twice?

That's a very good point, would you agree if we were prefixing the DSA
CPU port statistics with some kind of name, e.g: cpu_port_<name> or
something more compact?
-- 
Florian
