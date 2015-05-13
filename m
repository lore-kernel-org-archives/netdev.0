From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Wed, 13 May 2015 11:46:20 -0400
Message-ID: <20150513154620.GX11388@htj.duckdns.org>
References: <1431362494-9874-5-git-send-email-tj@kernel.org>
 <20150511.132339.403868463230045095.davem@davemloft.net>
 <20150511203745.GI11388@htj.duckdns.org>
 <20150512.192322.2233784105592482987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150512.192322.2233784105592482987.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, David.

On Tue, May 12, 2015 at 07:23:22PM -0400, David Miller wrote:
> Second question, is there an upper bound on this header size?
> Because if there is, it seems to me that there is no reason why we
> can't just avoid the fragmentation support altogether.
>
> The current code limits to 1000 bytes, and that limit seems arbitrary.
> Obviously this code is meant to work on interfaces with an ethernet
> MTU or larger.  So you could bump the limit enough to accomodate the
> new header size, yet still be within the real constraints.
> 
> What do you think?

Yeah, if we can bump the tx size enough to accomodate all messages,
it'd be great.  It can get fairly large tho.  The absolute maximum
right now is 8k.  While regular prink message bodies are capped
slightly below 1k, the dictionary printed through vprintk_emit()
doesn't have such length limit.  Another factor is that non-printables
are escaped using \xXX and vprintk_emit() is supposed to be useable
with transmitting binary data (like low level device error
descriptors) although I'm not sure anybody is doing that yet.

Thanks.

-- 
tejun
