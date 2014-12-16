From: rapier <rapier@psc.edu>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 13:58:20 -0500
Message-ID: <549080CC.3050704@psc.edu>
References: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:40323 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbaLPS6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 13:58:23 -0500
In-Reply-To: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm going to review those exports right now.

On 12/16/14, 1:24 PM, Alexei Starovoitov wrote:
> On Tue, Dec 16, 2014 at 9:50 AM, rapier <rapier@psc.edu> wrote:
>> +struct idr tcp_estats_idr;
>> +EXPORT_SYMBOL(tcp_estats_idr);
>> +static int next_id = 1;
>> +DEFINE_SPINLOCK(tcp_estats_idr_lock);
>> +EXPORT_SYMBOL(tcp_estats_idr_lock);
>> +
>> +int tcp_estats_wq_enabled __read_mostly = 0;
>> +EXPORT_SYMBOL(tcp_estats_wq_enabled);
>> +struct workqueue_struct *tcp_estats_wq = NULL;
>> +EXPORT_SYMBOL(tcp_estats_wq);
>> +void (*create_notify_func)(struct work_struct *work);
>> +EXPORT_SYMBOL(create_notify_func);
>> +void (*establish_notify_func)(struct work_struct *work);
>> +EXPORT_SYMBOL(establish_notify_func);
>> +void (*destroy_notify_func)(struct work_struct *work);
>> +EXPORT_SYMBOL(destroy_notify_func);
>> +unsigned long persist_delay = 0;
>> +EXPORT_SYMBOL(persist_delay);
>> +
>> +struct static_key tcp_estats_enabled __read_mostly = STATIC_KEY_INIT_FALSE;
>> +EXPORT_SYMBOL(tcp_estats_enabled);
> ...
>> +EXPORT_SYMBOL(tcp_estats_create);
> ...
>> +/* Do not call directly.  Called from tcp_estats_unuse() through call_rcu.
>> */
>> +void tcp_estats_free(struct rcu_head *rcu)
> ...
>> +EXPORT_SYMBOL(tcp_estats_free);
>
> imo that is very questionable design choice.
> export a lot of in-kernel bits to be used by out-of-tree kernel module?
>
