From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: change the order of actions in
 addif/delif
Date: Tue, 17 Sep 2013 09:24:08 -0700
Message-ID: <20130917092408.19a329b2@nehalam.linuxnetplumber.net>
References: <1379403883-16219-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:50219 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007Ab3IQQYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 12:24:13 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so5779163pdj.26
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 09:24:12 -0700 (PDT)
In-Reply-To: <1379403883-16219-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Sep 2013 15:44:43 +0800
Hong Zhiguo <honkiko@gmail.com> wrote:

> -	/* Device is already being bridged */
> -	if (br_port_exists(dev))
> +	/* Device is already being bridged or registered with other handler */
> +	if (br_port_exists(dev) || dev->rx_handler)
>  		return -EBUSY;

Direct access to dev->rx_handler should be avoided.
The error check should be in netdev_rx_handler_register.
