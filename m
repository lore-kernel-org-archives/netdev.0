From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Fri, 13 Feb 2009 18:24:26 -0800 (PST)
Message-ID: <20090213.182426.175113018.davem@davemloft.net>
References: <20090213192448.GA2929@ami.dom.local>
	<4995CD0F.8020307@hp.com>
	<20090213200014.GB2929@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, ole@ans.pl, pupilla@hotmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47267
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753548AbZBNCYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 21:24:33 -0500
In-Reply-To: <20090213200014.GB2929@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 13 Feb 2009 21:00:14 +0100

> On Fri, Feb 13, 2009 at 02:42:07PM -0500, Vlad Yasevich wrote:
> ...
> > Personally, I think pskb_expand_head should fix the skb->truesize.  This
> > way any subsequent clones will not trigger this warning.
> 
> Personally, I think there is no reason to call skb_truesize_bug() in
> anything but some #ifdef CONFIG_XX_DEBUG, if we ignore these reports
> for so long.

If skb->sk is non-NULL, fixing up the truesize will corrupt
socket memory accounting.

Anyways, Herbert and I have talked about %100 removing the
warning.
