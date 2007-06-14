From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Fri, 15 Jun 2007 00:00:51 +0200
Message-ID: <20070614220050.GB23266@electric-eye.fr.zoreil.com>
References: <20070613004154.GA4187@kvack.org> <20070613211859.GA22521@electric-eye.fr.zoreil.com> <46715FBA.3070302@iinet.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>
To: David Gundersen <gundy@iinet.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36977 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbXFNWFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 18:05:06 -0400
Content-Disposition: inline
In-Reply-To: <46715FBA.3070302@iinet.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Gundersen <gundy@iinet.net.au> :
[...]
> I might do some more thorough testing on the weekend to find out what
> the minimal changes required are to get things working.

In your patch, the first chunk of data (which is handed back to the
nic outside of rtl8169_xmit_frags) will not have is First fragment
bit set when nr_frags != 0. It makes me a bit nervous.

The NPQ part of your patch actually forces the start_xmit handler to
wait for all previously queued packets to be sent before telling the
nic that a packet may be available. I can understand that it will fix
the symptoms but it will implicitly shorten the TX queue a lot.

A pesky fever apart, I should be able to come with a patch before
the week end.

-- 
Ueimor
