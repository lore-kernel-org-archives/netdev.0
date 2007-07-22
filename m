From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] endianness bug in ip6_tunnel
Date: Sat, 21 Jul 2007 19:10:05 -0700 (PDT)
Message-ID: <20070721.191005.102771955.davem@davemloft.net>
References: <20070721081231.GM21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750941AbXGVCKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 22:10:06 -0400
In-Reply-To: <20070721081231.GM21668@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Sat, 21 Jul 2007 09:12:31 +0100

> IPV6_TCLASS_MASK is net-endian; what happens here is that we take
> a value and shove it into bits 20--27 of net-endian 32bit word.
> IOW, it's misannotated (it's really htonl, not ntohl) *and* the
> mask should be applied after conversion to net-endian, not before it.
> The former is harmless, the latter gives the wrong value on little-endian;
> As the matter of fact, on l-e it gives 0 - IPV6_TCLASS_MASK will be
> htonl(0x0ff00000), i.e. on little-endian we have (something << 20) & 0xff0...
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Applied, thanks Al.
