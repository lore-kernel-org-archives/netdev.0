From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 2/2] RTNL and flush_scheduled_work deadlocks
Date: Mon, 19 Feb 2007 08:18:28 +0100
Message-ID: <20070219071828.GA1900@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216103115.517f1a4c@freekitty> <45D60022.9060701@candelatech.com> <20070219065548.GA1686@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:46171 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750709AbXBSHPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 02:15:06 -0500
Content-Disposition: inline
In-Reply-To: <20070219065548.GA1686@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 07:55:48AM +0100, Jarek Poplawski wrote:
...
> So to use this we only need such changes:
> 
>  ... some_delayed_work_func(...)
>  {
> 	...
> -	rtnl_lock();
> +	rtnl_lock_work();
> 	...
> -	rtnl_unlock();
> +	rtnl_unlock_work();
>  }
> 
>  ... some_delayed_work_func(...)

Sorry! Of course:

  ... some_closing_with_flush_func(...)
>  {
> 	...
> +	rtnl_set_flush();
> 	flush_scheduled_work;
> 	/* or cancel_rearming_delayed_work(...); etc. */
> +	rtnl_unset_flush();
>  }

Jarek P.
