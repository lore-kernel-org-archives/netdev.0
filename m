From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 21 Jan 2009 12:34:20 -0800 (PST)
Message-ID: <20090121.123420.145043842.davem@davemloft.net>
References: <4976B82E.1080002@kernel.org>
	<m1fxjcucp8.fsf@fess.ebiederm.org>
	<20090121234502.66acbcf9@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tj@kernel.org, mingo@elte.hu,
	rusty@rustcorp.com.au, herbert@gondor.apana.org.au,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	netdev@vger.kernel.org, mathieu.desnoyers@polymtl.ca
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751319AbZAUUeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 15:34:18 -0500
In-Reply-To: <20090121234502.66acbcf9@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 Jan 2009 23:45:01 +1100

> This is crap. only a small fraction of these SNMP counters are
> close enough to the hot path to deserve per-cpu treatment.

Only if your router/firewall/webserver isn't hitting that code path
which bumps the counters you think aren't hot path.

It's a micro-DoS waiting to happen if we start trying to split
counters up into groups which matter for hot path processing
(and thus use per-cpu stuff) and those which don't (and thus
use atomics or whatever your idea is).
