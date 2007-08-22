From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 23:20:05 +0200
Message-ID: <20070822212005.GR32236@postel.suug.ch>
References: <200708221631.34234.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57755 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756982AbXHVVTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 17:19:44 -0400
Content-Disposition: inline
In-Reply-To: <200708221631.34234.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul Moore <paul.moore@hp.com> 2007-08-22 16:31
> We're currently talking about several different ideas to solve the problem, 
> including leveraging the sk_buff.secmark field, and one of the ideas was to 
> add an additional field to the sk_buff structure.  Knowing how well that idea 
> would go over (lead balloon is probably an understatement at best) I started 
> looking at what I might be able to remove from the sk_buff struct to make 
> room for a new field (the new field would be a u32).  Looking at the sk_buff 
> structure it appears that the sk_buff.dev and sk_buff.iif fields are a bit 
> redundant and removing the sk_buff.dev field could free 32/64 bits depending 
> on the platform.  Is there any reason (performance?) for keeping the 
> sk_buff.dev field around?  Would the community be open to patches which 
> removed it and transition users over to the sk_buff.iif field?  Finally, 
> assuming the sk_buff.dev field was removed, would the community be open to 
> adding a new LSM/SELinux related u32 field to the sk_buff struct?

This reminds of an idea someone brought up a while ago, it involved
having a way to attach additional space to an sk_buff for all the
different marks and other non-essential fields.

I think skb->dev is required because we need to have a reference on the
device while a packet being processing is put on a queue somewhere.
