From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2 1/2] bridge: implement missing ndo_uninit()
Date: Sat, 8 Apr 2017 09:30:42 -0400
Message-ID: <20170408093042.20b08c5d@plumbers-lap.home.lan>
References: <20170408114159.12722-1-idosch@mellanox.com>
        <20170408114159.12722-2-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <bridge@lists.linux-foundation.org>, <peter@svinota.eu>,
        <cera@cera.cz>, <mlxsw@mellanox.com>, <nikolay@cumulusnetworks.com>
To: <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36712 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752216AbdDHNas (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 09:30:48 -0400
Received: by mail-io0-f181.google.com with SMTP id l7so63121933ioe.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 06:30:47 -0700 (PDT)
In-Reply-To: <20170408114159.12722-2-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Apr 2017 14:41:58 +0300
<idosch@mellanox.com> wrote:

>  static void br_dev_free(struct net_device *dev)
>  {
> -	struct net_bridge *br = netdev_priv(dev);
> -
> -	free_percpu(br->stats);
>  	free_netdev(dev);
>  }
>  

Since the only thing left is free_netdev, you can now just set dev->destructor
to be free_netdev.
