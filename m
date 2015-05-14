From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Thu, 14 May 2015 00:39:17 -0400 (EDT)
Message-ID: <20150514.003917.1450039994643712704.davem@davemloft.net>
References: <20150511203745.GI11388@htj.duckdns.org>
	<20150512.192322.2233784105592482987.davem@davemloft.net>
	<20150513154620.GX11388@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: tj@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbbENEjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:39:21 -0400
In-Reply-To: <20150513154620.GX11388@htj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tejun Heo <tj@kernel.org>
Date: Wed, 13 May 2015 11:46:20 -0400

> Hello, David.
> 
> On Tue, May 12, 2015 at 07:23:22PM -0400, David Miller wrote:
>> Second question, is there an upper bound on this header size?
>> Because if there is, it seems to me that there is no reason why we
>> can't just avoid the fragmentation support altogether.
>>
>> The current code limits to 1000 bytes, and that limit seems arbitrary.
>> Obviously this code is meant to work on interfaces with an ethernet
>> MTU or larger.  So you could bump the limit enough to accomodate the
>> new header size, yet still be within the real constraints.
>> 
>> What do you think?
> 
> Yeah, if we can bump the tx size enough to accomodate all messages,
> it'd be great.  It can get fairly large tho.  The absolute maximum
> right now is 8k.  While regular prink message bodies are capped
> slightly below 1k, the dictionary printed through vprintk_emit()
> doesn't have such length limit.  Another factor is that non-printables
> are escaped using \xXX and vprintk_emit() is supposed to be useable
> with transmitting binary data (like low level device error
> descriptors) although I'm not sure anybody is doing that yet.

Yeah, 8K is too much to handle, oh well.

Ok I'm fine with this series from my end, and you can merge this
wherever the extended console support bits go.

Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks.
