From: Jason Lunz <lunz@falooley.org>
Subject: Re: Where is netif_rx() not safe to use?
Date: Mon, 12 May 2003 15:16:55 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnbbveq6.321.lunz@stoli.localnet>
References: <3ebfa567b38e59.35614148@not right> <20030512145943.GB27111@gtf.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jgarzik@pobox.com said:
>> I'd like to know if there are situations where netif_rx() is not safe to use. 
>> For example, is it safe to call from a timer or from dev->poll()?
> 
> Sure, that's fine.

from dev->poll()? It could work, but that's abusing the napi design.
netif_rx() is for non-napi drivers.  If a dev has a ->poll() method, it
should use netif_receive_skb().

Jason
