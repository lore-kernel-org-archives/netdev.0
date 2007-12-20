From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: dn_neigh_table vs pneigh_lookup/pneigh_delete
Date: Thu, 20 Dec 2007 11:24:20 +0000
Message-ID: <20071220112420.GA26048@fogou.chygwyn.com>
References: <47692696.1080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Patrick Caulfield <patrick@tykepenguin.com>,
	linux-decnet-user@lists.sourceforge.net
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:46744 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757375AbXLTLnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 06:43:39 -0500
Content-Disposition: inline
In-Reply-To: <47692696.1080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Dec 19, 2007 at 05:11:34PM +0300, Pavel Emelyanov wrote:
> Hi
> 
> The pneigh_lookup/delete silently concerns, that the 
> key_len of the table is more that 4 bytes. Look:
> 
>          u32 hash_val = *(u32 *)(pkey + key_len - 4);
> 
> The hash_val for the proxy neighbor entry is four last bytes
> from the pkey.
> 
> But the dn_neigh_tables' key_len is sizeof(__le16), that is 2,
> so setting (via netlink) the proxy neighbor entry for decnet 
> will cause this entry to reside in arbitrary hash chain.
> 
> Is this too bad for decnet?
> 
> Thanks,
> Pavel
The pneigh code is never used in DECnet, we only use the "normal"
part of the neigh code where the hash function was changed so that
it can be defined for each protocol (and thus doesn't suffer from
this problem)

Steve.
