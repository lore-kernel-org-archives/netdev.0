From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Mon, 01 Jun 2015 14:00:22 +0200
Message-ID: <1433160022.1884.18.camel@suse.com>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain>
	 <20150601005917.GB5320@kroah.com>
	 <alpine.LNX.2.20.1506010818110.3158@localhost.localdomain>
	 <1433144906.1557.2.camel@suse.com>
	 <alpine.LNX.2.20.1506011020001.3741@localhost.localdomain>
	 <1433155778.1884.12.camel@suse.de>
	 <alpine.LNX.2.20.1506011319330.4326@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: youtux@gmail.com, Greg KH <greg@kroah.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43461 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613AbbFAMBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 08:01:15 -0400
In-Reply-To: <alpine.LNX.2.20.1506011319330.4326@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-01 at 13:41 +0200, Enrico Mioso wrote:
> Thank you Oliver, thank you all for reading this thread and the attention.
> For a more detailed discussion and how we got here, you might google for the 
> thread:
> "Is this 32-bit NCM?"
> and
> "Is this 32-bit NCM?y" (follow up).
> Where the "y" letter comes from a mistake of mine.

Having read them it looks like the issues of padding and
sequence numbers are open.

> The specification does only mandate the position of the NTH (header). The rest 
> can be in any order and position in general. This will work with most devices: 
> except, of course, those from Huawei.

Indeed. And a redesign for crap devices looks like
a bad idea.

> Our aggregate looks something like this from my perspective (anyone correct me 
> in case):
> NTH: header
> NDP: contains indexing informations
> ethernet packet 1
> ethernet packet 2
> ...
> ethernet packet n;
> 
> While it should look like:
> NTH: header
> ethernet packet 1
> ethernet packet 2
> ...
> ethernet packet n;
> NDP: contains indexing informations
> 
> but, when introducing such a change: you might break other devices now working. 
> Infact, clearly there are multiple vendors producing NCM device, as you might 
> also see by looking at the dirver's comments.
> So in general, we should be able to dynamically change the way in which the 
> driver order things in the package.
> and that's why I initially proposed the "redesign".

OK, so the NDP needs to be at the end. However in the old thread
you state that this requires the NDP to be built between the
final aggregate and physically transmitting. I think this is a false
choice. You could just as well copy the NDP around provided you reserve
enough space at the end of the skb.

	Regards
		Oliver
