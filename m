From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH cumulus-4.1.y 2/5] vxlan: don't replace fdb entry if
 nothing changed
Date: Mon, 23 Jan 2017 09:02:11 -0800
Message-ID: <20170123090211.6bcd2afc@xeon-e3>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
        <1484984410-3304-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        ramanb@cumulusnetworks.com, jbenc@redhat.com, pshelar@ovn.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36237 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdAWRCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 12:02:36 -0500
Received: by mail-pg0-f44.google.com with SMTP id t6so46381243pgt.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 09:02:21 -0800 (PST)
In-Reply-To: <1484984410-3304-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 23:40:07 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> +	if (!vxlan_addr_equal(&rd->remote_ip, ip) ||
> +	    rd->remote_port != port ||
> +	    rd->remote_vni != vni ||
> +	    rd->remote_ifindex != ifindex) {
> +		dst_cache_reset(&rd->dst_cache);
> +		rd->remote_ip = *ip;
> +		rd->remote_port = port;
> +		rd->remote_vni = vni;
> +		rd->remote_ifindex = ifindex;
> +		return 1;
> +	}
> +

I think it would be clearer if negative logic was avoided.

	if (vxlan_addr_equal(&rd->remote_ip, ip) &&
	    rd->remote_port == port &&
	    rd->remote_vni == vni &&
            rd->ermote_ifindex == ifndex)
		return 1;

	dst_cache_reset ...
