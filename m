From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH V5 2/11] IB/ipoib: Notify the world
 before	doing unregister
Date: Sun, 23 Sep 2007 09:55:34 +0200
Message-ID: <46F61BF6.3000203@gmail.com>
References: <46F27692.3070404@voltaire.com> <46F2784C.9070806@voltaire.com> <adaabrhgvfa.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Moni Shoua <monis@voltaire.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:14100 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750753AbXIWHzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2007 03:55:43 -0400
In-Reply-To: <adaabrhgvfa.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > +		ipoib_slave_detach(cpriv->dev);
>  >  		unregister_netdev(cpriv->dev);
> 
> Maybe you already answered this before, but I'm still not clear why
> this notifier call can't just be added to the start of
> unregister_netdevice(), so we can avoid having driver needing to know
> anything about bonding internals?
> 
>  - R.

The action in bonding to a detach of slave is to unregister the master (see patch 10).
This can't be done from the context of unregister_netdevice itself (it is protected by rtnl_lock).

That's why I had to notify the detach before unregister begins.


