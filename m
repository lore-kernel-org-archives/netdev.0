From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2 2/2] bridge: netlink: register netdevice before
 executing changelink
Date: Sat, 8 Apr 2017 09:32:44 -0400
Message-ID: <20170408093244.593a8624@plumbers-lap.home.lan>
References: <20170408114159.12722-1-idosch@mellanox.com>
        <20170408114159.12722-3-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <bridge@lists.linux-foundation.org>, <peter@svinota.eu>,
        <cera@cera.cz>, <mlxsw@mellanox.com>, <nikolay@cumulusnetworks.com>
To: <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:38460 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752226AbdDHNcs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 09:32:48 -0400
Received: by mail-it0-f44.google.com with SMTP id y18so6593780itc.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 06:32:47 -0700 (PDT)
In-Reply-To: <20170408114159.12722-3-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Apr 2017 14:41:59 +0300
<idosch@mellanox.com> wrote:

> +	err = br_changelink(dev, tb, data);
> +	if (err)
> +		goto unregister;
> +
> +	return 0;
> +
> +unregister:
> +	unregister_netdevice(dev);
> +	return err;
>  }

Why use a goto? just do:
	err = br_changelink(dev, tb, data);
	if (err)
		unregister_netdevice(dev)
	return err;
}


The goto looks ugly
