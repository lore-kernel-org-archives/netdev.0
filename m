From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: mlx5: fix sizeof usage in health_care's reg_handler
Date: Sat, 03 Aug 2013 00:43:44 +0200
Message-ID: <51FC3620.3020401@redhat.com>
References: <1375438577-30933-1-git-send-email-dborkman@redhat.com> <20130802.151132.539136654627638979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7218 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754583Ab3HBWnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 18:43:52 -0400
In-Reply-To: <20130802.151132.539136654627638979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 12:11 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Fri,  2 Aug 2013 12:16:17 +0200
>
>> Therefore, I strongly assume sizeof(*health->health) is being meant
>> to be passed as an argument. Interestingly, there are actually no
>> in-tree users of mlx5_[un]register_health_report_handler(), but some
>> debugging modules might want to know the correct size instead.
>
> I want these hooks and infrastructure removed immediately.
>
> If there are no in-tree users there is no reason for them to
> exist at all.

Ok, I let Or handle that. Maybe he wants to add a user of it, instead.

I also noticed that coverty scanner found a couple of other issues,
e.g. outlen_write() in mlx5/core/cmd.c does a kzalloc() without
doing sanity checks on the user-passed allocation size, e.g. it
could even be a negative value passed to it.
