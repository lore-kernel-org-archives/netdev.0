From: Pavel Emelyanov <xemul@openvz.org>
Subject: dn_neigh_table vs pneigh_lookup/pneigh_delete
Date: Wed, 19 Dec 2007 17:11:34 +0300
Message-ID: <47692696.1080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	Patrick Caulfield <patrick@tykepenguin.com>,
	linux-decnet-user@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47106 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752907AbXLSOLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 09:11:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

The pneigh_lookup/delete silently concerns, that the 
key_len of the table is more that 4 bytes. Look:

         u32 hash_val = *(u32 *)(pkey + key_len - 4);

The hash_val for the proxy neighbor entry is four last bytes
from the pkey.

But the dn_neigh_tables' key_len is sizeof(__le16), that is 2,
so setting (via netlink) the proxy neighbor entry for decnet 
will cause this entry to reside in arbitrary hash chain.

Is this too bad for decnet?

Thanks,
Pavel
