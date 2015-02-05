From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] rtnetlink: ifla_vf_policy: fix misuses of NLA_BINARY
Date: Thu, 5 Feb 2015 17:52:36 +0000
Message-ID: <20150205175236.GA2712@casper.infradead.org>
References: <ceaf2a9c514600d14c9f6a89a8c38e553a85e9fe.1423158127.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56977 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbbBERwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:52:38 -0500
Content-Disposition: inline
In-Reply-To: <ceaf2a9c514600d14c9f6a89a8c38e553a85e9fe.1423158127.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/15 at 06:44pm, Daniel Borkmann wrote:
> ifla_vf_policy[] is wrong in advertising its individual member types as
> NLA_BINARY since .type = NLA_BINARY in combination with .len declares the
> len member as *max* attribute length [0, len].
> 
> The issue is that when do_setvfinfo() is being called to set up a VF
> through ndo handler, we could set corrupted data if the attribute length
> is less than the size of the related structure itself.
> 
> The intent is exactly the opposite, namely to make sure to pass at least
> data of minimum size of len.
> 
> Fixes: ebc08a6f47ee ("rtnetlink: Add VF config code to rtnetlink")
> Cc: Mitch Williams <mitch.a.williams@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Thomas Graf <tgraf@suug.ch>
