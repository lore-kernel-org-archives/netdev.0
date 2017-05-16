From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: x25: fix one potential use-after-free issue
Date: Tue, 16 May 2017 13:16:26 -0400 (EDT)
Message-ID: <20170516.131626.1752384449655666500.davem@davemloft.net>
References: <1494906774-16352-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, nhorman@tuxdriver.com,
        linux-x25@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: xiaolou4617@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752214AbdEPRQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:16:28 -0400
In-Reply-To: <1494906774-16352-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: linzhang <xiaolou4617@gmail.com>
Date: Tue, 16 May 2017 11:52:54 +0800

>  	return rc;
> -out_dev:
> +out_proc:
> +	x25_unregister_sysctl();
> +out_sysctl:
>  	unregister_netdevice_notifier(&x25_dev_notifier);
> -out_sock:
> +out_dev:
> +	dev_remove_pack(&x25_packet_type);
>  	sock_unregister(AF_X25);
> -out_proto:
> +out_sock:
>  	proto_unregister(&x25_proto);
>  	goto out;
>  }

Please do not name the labels this way, retain the current convention.
And that is the label names what resources get released not the
resource that we failed to acquire.

So the first label, should be "out_sysctl:" because that is what we
are releasing.
