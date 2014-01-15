From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bpf: do not use reciprocal divide
Date: Wed, 15 Jan 2014 08:07:57 -0800
Message-ID: <1389802077.31367.347.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140113214249.GK6586@order.stressinduktion.org>
	 <1389769361.31367.325.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140115080007.GA6638@osiris> <20140115091322.3a7740a7@mschwide>
	 <20140115105114.GB6638@osiris>
	 <1389795716.31367.333.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140115162623.39472f8f@mschwide>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	darkjames-ws@darkjames.pl, Mircea Gherzan <mgherzan@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Matt Evans <matt@ozlabs.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:46302 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAOQH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:07:59 -0500
Received: by mail-pa0-f49.google.com with SMTP id hz1so1319419pad.8
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:07:59 -0800 (PST)
In-Reply-To: <20140115162623.39472f8f@mschwide>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 16:26 +0100, Martin Schwidefsky wrote:

> The C compiler naturally can to a u32/u32 division, it either uses
> the "dlr" instruction which is unsigned, or uses a call to a function
> to do the u32/u32 math. See the lovely code in arch/s390/lib/div64.c
> for the kernel version of that code.

If the C code uses unsigned, then all arch jit code must use the same.

Behavior of the filter should not depend of jit being enabled or not ;)
