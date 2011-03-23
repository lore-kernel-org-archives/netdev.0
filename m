From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] myri10ge: small rx_done refactoring
Date: Wed, 23 Mar 2011 08:33:57 -0700
Message-ID: <20110323083357.457f10aa@nehalam>
References: <20110323124939.GA7834@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53990 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933050Ab1CWPeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 11:34:00 -0400
In-Reply-To: <20110323124939.GA7834@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Mar 2011 13:52:04 +0100
Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> Add lro_enable variable to read NETIF_F_LRO flag only once per napi poll
> call. This should fix theoretical race condition with
> myri10ge_set_rx_csum() and myri10ge_set_flags() where flag NETIF_F_LRO
> can be changed.

You may need a barrier or the race may still be there.
The driver seems to use mb() where wmb() is intended, and never use rmb()?



-- 
