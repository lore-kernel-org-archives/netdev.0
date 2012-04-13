From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 4/5] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Fri, 13 Apr 2012 15:01:26 -0700
Message-ID: <4F88A236.4040001@candelatech.com>
References: <1334248375-22967-1-git-send-email-greearb@candelatech.com> <1334248375-22967-5-git-send-email-greearb@candelatech.com> <4F8705E3.2010902@openwrt.org> <4F870828.4020708@candelatech.com> <alpine.DEB.2.02.1204122352001.29503@icf.org.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Georgiewskiy Yuriy <bottleman@icf.org.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41438 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378Ab2DMWBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 18:01:38 -0400
In-Reply-To: <alpine.DEB.2.02.1204122352001.29503@icf.org.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2012 12:53 PM, Georgiewskiy Yuriy wrote:
> On 2012-04-12 09:51 -0700, Ben Greear wrote Florian Fainelli:
>
> BG>On 04/12/2012 09:42 AM, Florian Fainelli wrote:
> BG>>  Hi,
> BG>>
> BG>>  Le 04/12/12 18:32, greearb@candelatech.com a ?crit :
> BG>>  >  From: Ben Greear<greearb@candelatech.com>
> BG>>  >
> BG>>  >  The signal and noise are forced to be positive since ethtool
> BG>>  >  deals in unsigned 64-bit values and this number should be human
> BG>>  >  readable. This gives easy access to some of the data formerly
> BG>>  >  exposed in the deprecated /proc/net/wireless file.
> BG>>
> BG>>  Uh, that's misleading, the signal and noise values are typically negative,
> BG>>  so one needs to think about mentally adding a minus sign if he/she wants to
> BG>>  understand it. Does not ethtool know about 32-bits signed integers?
> BG>
> BG>Ethtool stats only supports u64.  I think it's easy enough for
> BG>humans or programs to add the negative sign.  Can signal or noise
> BG>ever be>  0?  If so, that could actually break something that depends
> BG>on flipping the value to negative....
>
> Don't know is this is a bug or it's reaaly can be positive, but:
>
> iw dev mp0 station dump
> Station 00:02:6f:b8:94:d3 (on mp0)
>      inactive time:	49 ms
>      rx bytes:	36318341
>      rx packets:	271741
>      tx bytes:	4180152
>      tx packets:	35445
>      tx retries:	7724
>      tx failed:	123
>      signal:  	1 dBm
>      signal avg:	-2 dBm

So, how about I just cast it to u8 and pass that to user-space.
Let user-space apps that care just understand the data is really just
a signed 8-bit number for now.

For the future, we can figure out a way to make ethtool
API deal with different data types better.


	if (survey.filled & SURVEY_INFO_NOISE_DBM)
		data[i++] = (u8)(survey.noise & 0xff);
	else

...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
