From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] netlink: trim skb to exact size to avoid MSG_TRUNC
Date: Tue, 13 Oct 2015 10:56:00 +0200
Message-ID: <20151013085600.GA23077@pox.localdomain>
References: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ronen Arad <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34083 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbbJMI4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 04:56:03 -0400
Received: by wicgb1 with SMTP id gb1so79794754wic.1
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 01:56:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/15 at 06:15pm, Ronen Arad wrote:
> The available room in the skb allocated in netlink_dump for iproute2
> show requests (e.g. "ip link [show]", "bridge [-c] vlan show") should
> be trimmed to the exact size requested in order to avoid MSG_TRUNC flag
> set in netlink_recvmg.
> This was handled properly for small skb allocated when no interface has
> many VLANs configured. This patch applies the same logic to larger skbs
> which are allocated using the calculated min_dump_alloc size.
> 
> Signed-off-by: Ronen Arad <ronen.arad@intel.com>

Wouldn't this imply a bug in which rtnl_calcit() does not account for
some data that is later dumped? How else could the skb end up being
larger than what alloc_size accounts for at this point unless we end
up stuffing 2x smallish messages into the padded projection of the
calculated maximum message size of that type. Is that what you are
seeing?

Regardless of that, alloc_size is likely larger than nlk->max_recvmsg_len
anyway at this point so unless the reader suddenly provides a different
message size or does peeking it will likely still be truncated.

I'm just trying to understand which exact case you are solving here.
