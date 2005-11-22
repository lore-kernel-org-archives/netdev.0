From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Tue, 22 Nov 2005 14:37:13 -0800 (PST)
Message-ID: <20051122.143713.101129339.davem@davemloft.net>
References: <20051116235813.GS5735@stusta.de>
	<20051121155955.GW16060@stusta.de>
	<4381F2D2.5000605@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, evil@g-house.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030207AbVKVWhO@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <4381F2D2.5000605@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Nov 2005 17:16:18 +0100

> Adrian Bunk wrote:
> > This patch therefore changes NET_CLS back to the 2.6.14 status quo of 
> > being an user-visible option.
> 
> I disagree with this patch. NET_CLS enables the infrastructure support
> for classifiers. Users generally don't care about infrastructure but
> directly usable things, so I'd prefer to have it automatically selected. 
> And there are lots of other cases where enabling a module causes changes
> in the kernel image. Some examples include some of the netfilter stuff,
> the IPsec transforms, NET_CLS_ROUTE4, the ieee80211 stuff, and a lot
> more.

I agree with Patrick.

Changing config options of any kind can result in the main kernel
image needing to be rebuilt.  One thing we can do to prevent human
mistakes, is to make the "make modules" pass do a quick "is vmlinux
uptodate?" check, and if not print out an error message explaining the
situation and aborting the "make modules" attempt.
