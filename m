From: David Miller <davem@davemloft.net>
Subject: Re: [WEXT 8/12]: Pull top-level ioctl dispatch logic into helper
 function.
Date: Tue, 03 Jun 2008 07:34:53 -0700 (PDT)
Message-ID: <20080603.073453.69571531.davem@davemloft.net>
References: <20071221.205623.141035851.davem@davemloft.net>
	<20080121194758.6139.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: mokuno@sm.sony.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754042AbYFCOe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 10:34:57 -0400
In-Reply-To: <20080121194758.6139.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Date: Mon, 21 Jan 2008 20:16:19 +0900

I am working on these patches again, thank you for your
extreme patience...

> > +int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
> > +		      void __user *arg)
> > +{
> > +	int ret = wext_ioctl_dispatch(net, ifr, cmd,
> > +				      ioctl_standard_call,
> > +				      ioctl_private_call);
> > +
> > +	if (ret > 0 &&
> 
> As the return value 0 is legal, should we allow copybacking in the case
> of 'ret == 0'?
> 
> Same issue exists in compat_wext_handle_ioctl() of the #9 patch.

You are right, I wonder why I made this strange test.  It should
definitely be "ret >= 0".  I'll make that fix.
