From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net] rtnetlink: Fix the IFLA_PHYS_PORT_NAME TLV to
 include terminating NULL
Date: Tue, 9 May 2017 14:31:07 +0200
Message-ID: <20170509123107.GG10395@distanz.ch>
References: <1494331922-16451-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, zhangshengju@cmss.chinamobile.com,
        roopa@cumulusnetworks.com, sd@queasysnail.net,
        bblanco@plumgrid.com, minipli@googlemail.com, nogahf@mellanox.com,
        moshe@mellanox.com, rshearma@brocade.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, David Ahern <dsa@cumulusnetworks.com>
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:38119 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752682AbdEIMbL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:31:11 -0400
Content-Disposition: inline
In-Reply-To: <1494331922-16451-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-09 at 14:12:02 +0200, Yotam Gigi <yotamg@mellanox.com> wrote:
> The IFLA_PHYS_PORT_NAME rtnetlink TLV length does not include the
> terminating NULL character, which is different from other string typed
> TLVs. Due to the fact that libnl checks for the terminating NULL in every
> string typed attribute, it crashes on every RTM_GETLINK response on
> drivers that implement ndo_get_phys_port_name.
> 
> Make the fill_phys_port_name function include the terminating NULL in the
> TLV size by using the nla_put_string helper function.
> 
> Fixes: db24a9044ee1 ("net: add support for phys_port_name")
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> ---
> Please consider this for stable too. Thanks!

This is already fixed in commit 77ef033b687c ("rtnetlink: NUL-terminate
IFLA_PHYS_PORT_NAME string").
