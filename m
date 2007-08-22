From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 4/7] fs_enet: mac-fcc: Eliminate __fcc-* macros.
Date: Wed, 22 Aug 2007 16:17:01 -0500
Message-ID: <46CCA7CD.3060109@freescale.com>
References: <20070817175320.GA8259@ld0162-tx32.am.freescale.net>	<20070817175402.GD9218@ld0162-tx32.am.freescale.net> <20070823010826.6ae3452d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:52033 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760257AbXHVVRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:17:18 -0400
In-Reply-To: <20070823010826.6ae3452d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Bordug wrote:
>>-#define W8(_p, _m, _v)	__fcc_out8(&(_p)->_m, (_v))
>>-#define R8(_p, _m)	__fcc_in8(&(_p)->_m)
>>+#define W8(_p, _m, _v)	out_8(&(_p)->_m, (_v))
>>+#define R8(_p, _m)	in_8(&(_p)->_m)
>> #define S8(_p, _m, _v)	W8(_p, _m, R8(_p, _m) | (_v))
>> #define C8(_p, _m, _v)	W8(_p, _m, R8(_p, _m) & ~(_v))
>> 
>>@@ -290,7 +281,7 @@ static void restart(struct net_device *dev)
>> 
>> 	/* clear everything (slow & steady does it) */
>> 	for (i = 0; i < sizeof(*ep); i++)
>>-		__fcc_out8((char *)ep + i, 0);
>>+		out_8((char *)ep + i, 0);
>> 
> 
> Perhaps W8() here, to keep consistency?

W8 expects a struct pointer and member, which we don't have here.

-Scott
