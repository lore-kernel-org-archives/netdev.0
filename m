From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: GRE: Refactor GRE tunneling code.
Date: Tue, 2 Apr 2013 09:44:42 +0200
Message-ID: <20130402074441.GA28378@unicorn.suse.cz>
References: <20130402063421.GA4826@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49375 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab3DBHoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 03:44:44 -0400
Content-Disposition: inline
In-Reply-To: <20130402063421.GA4826@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 02, 2013 at 09:34:21AM +0300, Dan Carpenter wrote:
> 
> I had a question about c54419321455: "GRE: Refactor GRE tunneling code."
> from Mar 25, 2013:
> 
> net/ipv4/ip_gre.c
>    392                  if (tpi->flags&TUNNEL_CSUM &&
>    393                      !(skb_shinfo(skb)->gso_type & SKB_GSO_GRE)) {
>    394                          *(__sum16 *)ptr = 0;
>    395                          *(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
>    396                                                                   skb->len, 0));
> 
> What are we doing here when we set *ptr = 0 and then reset it on the
> next line?  Is there a ptr++ or ptr-- missing?

AFAICS, skb_checksum() calculates the checksum over a block containing
the checksum field the result is to be written into (which is where ptr
points). This fields needs to be reset first.

                                                        Michal Kubecek
