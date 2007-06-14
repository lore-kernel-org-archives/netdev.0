From: "Ayyappan Veeraiyan" <Ayyappan.Veeraiyan@intel.com>
Subject: Re: [ANNOUNCE] new driver ixgbe for Intel(R) 10GbE PCI Express adapters.
Date: Wed, 13 Jun 2007 17:06:57 -0700
Message-ID: <ae4a4a920706131706m6993e96bhdab638850b4769cf@mail.gmail.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain>
	 <20070613230513.GB22521@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.243]:38784 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755070AbXFNAG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 20:06:57 -0400
Received: by ag-out-0708.google.com with SMTP id 35so928aga
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 17:06:57 -0700 (PDT)
In-Reply-To: <20070613230513.GB22521@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/13/07, Francois Romieu <romieu@fr.zoreil.com> wrote:

Please ignore my previous response. Forgot to reply_all..

>
> o ixgbe_clean_tx_irq() is issued from the NAPI poll handler (as the
>   name suggests...). Its locking will probably cause a deadlock if
>   it is interrupted and a call to netpoll_send_skb follows.
>

netpoll_send_skb should not deadlock because ixgbe_xmit_frame should
bail out because of this...

      if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
               /* Collision - tell upper layer to requeue */
               return NETDEV_TX_LOCKED;

Right?

The LLTX and tx_lock handling in the driver is not clean and I am
working on to fix it. Also will make sure we are handling the net_poll
case correctly...

Thanks for the feedback..

Ayyappan
