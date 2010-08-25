From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Wed, 25 Aug 2010 11:04:09 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1008251103150.24022@obet.zrqbmnf.qr>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>  <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>  <1282570935.7198.5.camel@powerslave>  <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>  <1282589101.7198.28.camel@powerslave>
  <alpine.LNX.2.01.1008232052170.31619@obet.zrqbmnf.qr>  <1282633220.7198.123.camel@powerslave>  <alpine.LNX.2.01.1008240921230.24349@obet.zrqbmnf.qr> <1282720198.18016.72.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Changli Gao <xiaosuo@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:34883 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627Ab0HYJEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 05:04:11 -0400
In-Reply-To: <1282720198.18016.72.camel@powerslave>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2010-08-25 09:09, Luciano Coelho wrote:
>> 
>> Indeed so. But you did not invent any new interface. You are reusing
>> files, which can be protected by DAC modes, or LSMs doing
>> funky-stuff. xt_{condition,recent,..} already implement file modes,
>> but does it check for it? Well no, because fs/namei.c does it for
>> them. As for LSMs, well, I hope they do cater for testing for
>> capability bits.
>
>I dug deeper into the code and I can see that /sys/net has capability
>checks (implemented in netdev_store() in net-sysfs.c) and nobody without
>CAP_NET_ADMIN will be able to write to the files there.  But in procfs I
>couldn't see anything similar and anyone with file write permissions can
>modify the files in /proc/net/*.

I did not say there was. fs/ will handle the DAC part, and if you
wanted MAC/capability checking/other sparkles, an LSM sounds like
the right spot.
