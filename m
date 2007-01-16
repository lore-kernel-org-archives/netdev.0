From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]: 8139cp: Don't blindly enable interrupts in cp_start_xmit
Date: Tue, 16 Jan 2007 21:22:17 +0100
Message-ID: <20070116202217.GA9369@electric-eye.fr.zoreil.com>
References: <45ABAE69.4070105@redhat.com> <20070115195635.GA14205@electric-eye.fr.zoreil.com> <45ACE4B6.3040809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54193 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbXAPUZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 15:25:17 -0500
To: Chris Lalancette <clalance@redhat.com>
Content-Disposition: inline
In-Reply-To: <45ACE4B6.3040809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Lalancette <clalance@redhat.com> :
[...]
>      Thanks for the comments.  While the patch you sent will help, there are
> still other places that will have problems.  For example, in netpoll_send_skb,
> we call local_irq_save(flags), then call dev->hard_start_xmit(), and then call
> local_irq_restore(flags).  This is a similar situation to what I described
> above; we will re-enable interrupts in cp_start_xmit(), when netpoll_send_skb
> doesn't expect that, and will probably run into issues.
>      Is there a problem with changing cp_start_xmit to use the
> spin_lock_irqsave(), besides the extra instructions it needs?

No. Given the history of locking in netpoll and the content of
Documentation/networking/netdevices.txt, asking Herbert which rule(s)
the code is supposed to follow seemed safer to me.

You can forget my patch.

Please resend your patch inlined to Jeff as described in
http://linux.yyz.us/patch-format.html.

-- 
Ueimor
