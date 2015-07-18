From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv2 RFC net-next] net/vxlan: Fix kernel unaligned access in
 __vxlan_find_mac
Date: Sat, 18 Jul 2015 06:46:41 +0200
Message-ID: <20150718044641.GD30336@oracle.com>
References: <20150717200031.GB30336@oracle.com>
 <1437174422.2495.75.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37679 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbbGREqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 00:46:54 -0400
Content-Disposition: inline
In-Reply-To: <1437174422.2495.75.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (07/17/15 16:07), Joe Perches wrote:
> On Fri, 2015-07-17 at 22:00 +0200, Sowmini Varadhan wrote:
> > __vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
> > which triggers unaligned access messages, so rearrange vxlan_fdb
> > to avoid this in the most non-intrusive way.
> 
> What arch does this?

sparc.

BTW, I was also getting a lot of alignment errors from 
vxlan_xmit_skb (vxh comes out unaligned) for the IPv6 path.
I did not have time to investigate/fix this correctly- not sure
if this is specific to v6.

--Sowmini
