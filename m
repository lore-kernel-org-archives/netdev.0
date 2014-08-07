From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Silicom bypass driver promote from staging
Date: Thu, 7 Aug 2014 23:51:15 +0200
Message-ID: <20140807215115.GB19520@electric-eye.fr.zoreil.com>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
 <20140805150957.GC27303@kroah.com>
 <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49855 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaHGVvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 17:51:23 -0400
Content-Disposition: inline
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Hendel <david@silicom.co.il> :
[...]
> Let me know how we can proceed with that. what should be the next step.

Location is the easy part. Getting things reviewed is a different story.

You shouldn't expect reviewers to swallow 300k of code (600k / 2 due to
removal). Please split the submitted patch into smaller, self-consistent,
logical ones.

Notwithstanding Stephen and Jeff's remarks, you should also:
- remove the (out-)commented code 
- reconsider the use of gorilla class macros vs plain functions
- stop casting ioremap return into long, then later into void *. It's
  void __iomem * and should stay so.
- use a consistent locking style and remove BP_SYNC_FLAG
- fix the 80 cols limit problem(s) (hardly surprizing after 5 levels of
  nested "if")
- avoid redefining stuff from include/uapi/linux/mii.h
  I may be wrong but BPCTLI_MII_CR_POWER_DOWN smells of BMCR_PDOWN and
  BPCTLI_PHY_CONTROL, well, MII_BMCR ?
- avoid returning with spinlock held (read_reg, wdt_pulse)
- start explaining what did change between two submissions

-- 
Ueimor
