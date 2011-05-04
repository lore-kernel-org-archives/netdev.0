From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [ethtool PATCH] FW dump support
Date: Wed, 04 May 2011 19:25:22 +0100
Message-ID: <1304533522.2926.58.camel@bwh-desktop>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
	 ,<1304530807.2926.28.camel@bwh-desktop>
	 <49395329523DD64492581B505F80C86D5A5BCD3990@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: anirban.chakraborty@qlogic.com, netdev@vger.kernel.org,
	--no-chain-reply-to@mv.qlogic.com, davem@davemloft.net
To: Ajit.Khaparde@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14653 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab1EDSZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:25:26 -0400
In-Reply-To: <49395329523DD64492581B505F80C86D5A5BCD3990@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 11:15 -0700, Ajit.Khaparde@Emulex.Com wrote:
> ________________________________________
> From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] On Behalf Of Ben Hutchings [bhutchings@solarflare.com]
> Sent: Wednesday, May 04, 2011 12:40 PM
> To: anirban.chakraborty@qlogic.com
> Cc: netdev@vger.kernel.org; --no-chain-reply-to@mv.qlogic.com; davem@davemloft.net
> Subject: Re: [ethtool PATCH] FW dump support
> 
> > On Mon, 2011-05-02 at 16:29 -0700, anirban.chakraborty@qlogic.com wrote:
> >> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> >>
> >> Added support to take FW dump via ethtool.
> > [...]
> >> --- a/ethtool.c
> >> +++ b/ethtool.c
> > [...]
> >> @@ -263,6 +270,12 @@ static struct option {
> >>               "Get Rx ntuple filters and actions\n" },
> >>      { "-P", "--show-permaddr", MODE_PERMADDR,
> >>               "Show permanent hardware address" },
> >> +    { "-W", "--get-dump", MODE_GET_DUMP,
> >> +             "Get dump level\n" },
> >> +    { "-Wd", "--get-dump-data", MODE_GET_DUMP_DATA,
> >> +             "Get dump data", "FILENAME " "Name of the dump file\n" },
> >
> > The short options should only include one letter.  Also the general
> > pattern is that 'get' options use lower-case letters and 'set' options
> > use upper-case letters.  No, I'm not sure how best to handle a set of 3
> > options.  Maybe you can combine --get-dump and --get-dump-data, making
> > the filename optional?
> 
> ethtool already has "-f" option to flash/write the FW image.
> Can you use "-F" to get the FW dump data out?
> And then may be, these options can be extended to get the get/set dump levels?

Although '-F' would be nicely mnemonic, firmware update and dump are
different enough that I don't think they make sense as a pair.  If a
driver implements both then there is the risk of a typo causing the
firmware image file to be overwritten with a firmware dump.  I also
don't think it's possible to extend the '-f' option without breaking
compatibility with scripts that already use it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

