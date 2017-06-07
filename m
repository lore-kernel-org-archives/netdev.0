From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add TCPMemoryPressuresChrono counter
Date: Wed, 07 Jun 2017 14:54:48 -0400 (EDT)
Message-ID: <20170607.145448.152856288455996460.davem@davemloft.net>
References: <1496776767.736.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdFGSyv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 14:54:51 -0400
In-Reply-To: <1496776767.736.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Jun 2017 12:19:27 -0700

> @@ -320,18 +320,37 @@ struct tcp_splice_state {
>   * All the __sk_mem_schedule() is of this nature: accounting
>   * is strict, actions are advisory and have some latency.
>   */
> -int tcp_memory_pressure __read_mostly;
> +unsigned long tcp_memory_pressure __read_mostly;
>  EXPORT_SYMBOL(tcp_memory_pressure);

I know it is not strictly related to your change, but if you are
adding new exports in this area let's do it properly.

The existing tcp_memory_pressure export, as well as these two:

...
>  EXPORT_SYMBOL(tcp_enter_memory_pressure);
...
> +EXPORT_SYMBOL(tcp_leave_memory_pressure);

ought to be EXPORT_SYMBOL_GPL().  They are exported for the sake of
ipv6 TCP support, and nothing else.

I'll apply this with that fixed.

Thanks Eric.
