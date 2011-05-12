From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 net-next-2.6 2/3] qlcnic: Take FW dump via ethtool
Date: Thu, 12 May 2011 22:02:47 +0100
Message-ID: <1305234167.5214.70.camel@bwh-desktop>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1305154448-9687-4-git-send-email-anirban.chakraborty@qlogic.com>
	 <1305221242.5214.36.camel@bwh-desktop>
	 <F9877D83-226B-4C7A-AD01-E9AA441AD1CD@qlogic.com>
	 <1305227938.5214.48.camel@bwh-desktop>
	 <135A6631-C557-4C01-9FDD-F9E58F555168@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42212 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758660Ab1ELVCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 17:02:51 -0400
In-Reply-To: <135A6631-C557-4C01-9FDD-F9E58F555168@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 13:54 -0700, Anirban Chakraborty wrote:
> On May 12, 2011, at 12:18 PM, Ben Hutchings wrote:
[...]
> > What prevents this sequence:
> > 
> > 1. Driver detects firmware dump is required, and creates the dump
> > (length L1).
> > 2. User changes firmware dump flags through ethtool.
> > 3. User starts to save firmware dump through ethtool:
> >   a. ethtool utility reads dump length (= L1) and allocates user buffer
> >   b. ethtool utility reads dump:
> >   c. ethtool core reads dump length (L1) and allocates kernel buffer
> > 4. Meanwhile, driver detects firmware dump is required again, and
> > creates a new dump (length L2, since dump flags changed)
> 
> This step won't happen as driver ensures that if a dump is taken that is not
> cleared yet by ethtool utility, it is not going to take any further dump. So, until
> the get_dump_data() has been called to fetch the dump data, changing dump
> flag (and hence dump size) will not have any effect.
> In 3 above, ethtool core created a buffer of L1 size but hasn't yet called 
> get_dump_data() of the driver, so driver is still holding onto its previously
> dumped data even though capture mask has been changed and the driver
> encountered a situation where it ought to take the dump.

OK, that sounds safe.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

