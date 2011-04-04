From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Mon, 4 Apr 2011 12:44:08 -0700
Message-ID: <BANLkTik=hsDPjLUx+evW698moouj5A35jw@mail.gmail.com>
References: <20110403.220305.71570981.davem@davemloft.net>
	<20110403.222341.149838774.davem@davemloft.net>
	<BANLkTik__2JSNHXf4JBDqQPgDmMgsT9Lug@mail.gmail.com>
	<20110404.095207.137846978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54847 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab1DDToK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 15:44:10 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p34JiAxN009270
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2011 12:44:10 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz17.hot.corp.google.com with ESMTP id p34JhjvX017034
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2011 12:44:08 -0700
Received: by pxi1 with SMTP id 1so2290151pxi.23
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 12:44:08 -0700 (PDT)
In-Reply-To: <20110404.095207.137846978.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm simply saying to get rid of the ARCH_HAS_NOCACHE_UACCESS ifdefs
> you're adding to the networking code, since linux/uaccess.h makes sur=
e
> that a nop version of the nocache routines are available always.
>
> If you ifdef the networking bits unnecessarily, those code paths
> won't get build tested in the majority of my test builds, which are
> on sparc64. =A0So I want to avoid the conditionalized compilation if
> at all possible.
>

I'll take them out, but that will result in one needless conditional
in the transmit path for architectures that don't support the no cache
copy, which seems to be everything except x86!?
