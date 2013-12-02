From: David Miller <davem@davemloft.net>
Subject: Re: gem csum breakage with 018c5bba (Handle CHECKSUM_COMPLETE more
 adequately ...)
Date: Mon, 02 Dec 2013 13:59:02 -0500 (EST)
Message-ID: <20131202.135902.408377838919681103.davem@davemloft.net>
References: <B8BCE323-6F65-4D14-BD4A-BFA07C3ED290@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, edumazet@google.com,
	herbert@gondor.apana.org, linux-kernel@vger.kernel.org,
	benh@kernel.crashing.org
To: agraf@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B8BCE323-6F65-4D14-BD4A-BFA07C3ED290@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Graf <agraf@suse.de>
Date: Fri, 22 Nov 2013 19:08:16 +0100

> With current Linus' master tree my ibook started emitting a lot of
> annoying csum calculation warnings. I've bisected it down to the
> commit seen in the subject line, but I suppose the real problem lies
> somewhere a lot deeper and only gets revealed thanks to the more
> clever checksum logic applied now.
> 
> Any ideas how to dig further into this?

Ok, I'm going to revert this commit, for several reasons.

In addition to the problem you are running into, it just occurred to me
that if the __pskb_trim() call fails, we'll leave a corrupted checksum
in the SKB.

Thanks for your report.
