From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/5] Call netif_carrier_off() after register_netdev()
Date: Tue, 14 Aug 2012 23:47:57 +0100
Message-ID: <1344984477.2690.85.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344940135-17079-1-git-send-email-shchepetkov@ispras.ru>
	 <20120814.140019.1016184364798213214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shchepetkov@ispras.ru>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ldv-project@ispras.ru>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814.140019.1016184364798213214.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-08-14 at 14:00 -0700, David Miller wrote:
> From: Ilya Shchepetkov <shchepetkov@ispras.ru>
> Date: Tue, 14 Aug 2012 14:28:50 +0400
> 
> > Hi,
> > 
> > There are several patches on the subject:
> > 	
> > 	31bde1ceaa873bcaecd49e829bfabceacc4c512d
> > 	c55ad8e56b983f03589b38b4504b5d1f41161ff8
> > 	e826eafa65c6f1f7c8db5a237556cebac57ebcc5
> > 	0d672e9f8ac320c6d1ea9103db6df7f99ea20361
> > 	6a3c869a6021f4abcd69aa5fbb15c63f69eb36fe
> > 
> > In 2008, David Miller wrote in his commit:
> > (b47300168e770b60ab96c8924854c3b0eb4260eb)
> > 
> >>net: Do not fire linkwatch events until the device is registered.
> > 
> >>Several device drivers try to do things like netif_carrier_off()
> >>before register_netdev() is invoked.  This is bogus, but too many
> >>drivers do this to fix them all up in one go.
> > 
> > But I don't understand what will happen in this case?
> 
> Sigh... I would strongly suggest that when you don't understand
> something you leave it alone until you do.
> 
> You can't do the netif_carrier_off() after the device register because
> at the precise moment the device is registered it can be openned in
> parallel on another cpu and thus cause the entire carrier state
> to be changed.
> 
> Therefore if you do the netif_carrier_off() afterwards, it might
> be overwriting state changes made in another context.
> 
> Please just leave this code alone.

But if you do it beforehand then it doesn't have the intended effect.
(Supposed to be fixed by 22604c866889c4b2e12b73cbf1683bda1b72a313, which
had to be reverted: c276e098d3ee33059b4a1c747354226cec58487c.)

So you have to do it after, but without dropping the RTNL lock in
between.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
