From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: Provide CPU port statistics to master
 netdev
Date: Wed, 27 Apr 2016 14:43:02 -0700
Message-ID: <57213266.8020004@gmail.com>
References: <1461782714-13471-1-git-send-email-f.fainelli@gmail.com>
 <20160427190308.GE29024@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34847 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbcD0VpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 17:45:20 -0400
Received: by mail-pa0-f43.google.com with SMTP id iv1so24247795pac.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 14:45:19 -0700 (PDT)
In-Reply-To: <20160427190308.GE29024@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/04/16 12:03, Andrew Lunn wrote:
>> +	if (stringset == ETH_SS_STATS && ds->drv->get_strings) {
>> +		ndata = data + mcount * len;
>> +		/* This function copies ETH_GSTRINGS_LEN bytes, we will mangle
>> +		 * the output after to prepend our CPU port prefix we
>> +		 * constructed earlier
>> +		 */
>> +		ds->drv->get_strings(ds, cpu_port, ndata);
>> +		count = ds->drv->get_sset_count(ds);
>> +		for (i = 0; i < count; i++) {
>> +			memmove(ndata + (i * len + sizeof(pfx)),
>> +				ndata + i * len, len - sizeof(pfx));
>> +			memcpy(ndata + i * len, pfx, sizeof(pfx));
> 
> Hi Florian
> 
> Did you check what happens if this causes the NULL terminator to be
> discarded? Does ethtool handle that? As i said before, it is unclear
> if one is required.

I just did yes. So ethtool has a do_gstringset() function which
NULL-terminates every strings set except the statistics kind
(ETH_SS_STATS or ETH_SS_PHY_STATS) but this is not much of a problem
because it limits the output to ETH_GSTRING_LEN anyway.

After injecting a bit of error in net/dsa/slave.c to have a much bigger
prefix making us push the stats names, the stats are correcty truncated
by ethtool. So we seem to be good to go with the current code in kernel
and user space.
-- 
Florian
