From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 10:24:31 -0800
Message-ID: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: rapier <rapier@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:52831 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbaLPSYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 13:24:32 -0500
Received: by mail-qg0-f51.google.com with SMTP id e89so10725365qgf.10
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 10:24:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014 at 9:50 AM, rapier <rapier@psc.edu> wrote:
> +struct idr tcp_estats_idr;
> +EXPORT_SYMBOL(tcp_estats_idr);
> +static int next_id = 1;
> +DEFINE_SPINLOCK(tcp_estats_idr_lock);
> +EXPORT_SYMBOL(tcp_estats_idr_lock);
> +
> +int tcp_estats_wq_enabled __read_mostly = 0;
> +EXPORT_SYMBOL(tcp_estats_wq_enabled);
> +struct workqueue_struct *tcp_estats_wq = NULL;
> +EXPORT_SYMBOL(tcp_estats_wq);
> +void (*create_notify_func)(struct work_struct *work);
> +EXPORT_SYMBOL(create_notify_func);
> +void (*establish_notify_func)(struct work_struct *work);
> +EXPORT_SYMBOL(establish_notify_func);
> +void (*destroy_notify_func)(struct work_struct *work);
> +EXPORT_SYMBOL(destroy_notify_func);
> +unsigned long persist_delay = 0;
> +EXPORT_SYMBOL(persist_delay);
> +
> +struct static_key tcp_estats_enabled __read_mostly = STATIC_KEY_INIT_FALSE;
> +EXPORT_SYMBOL(tcp_estats_enabled);
...
> +EXPORT_SYMBOL(tcp_estats_create);
...
> +/* Do not call directly.  Called from tcp_estats_unuse() through call_rcu.
> */
> +void tcp_estats_free(struct rcu_head *rcu)
...
> +EXPORT_SYMBOL(tcp_estats_free);

imo that is very questionable design choice.
export a lot of in-kernel bits to be used by out-of-tree kernel module?
