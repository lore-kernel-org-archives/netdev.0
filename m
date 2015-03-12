From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] bonding: Handle notifications during
 work-queue processing gracefully
Date: Thu, 12 Mar 2015 02:31:44 -0700
Message-ID: <1426152704.11398.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426139676-27124-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32953 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034AbbCLJbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 05:31:46 -0400
Received: by padet14 with SMTP id et14so19182377pad.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 02:31:46 -0700 (PDT)
In-Reply-To: <1426139676-27124-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 22:54 -0700, Mahesh Bandewar wrote:

> +static inline void bond_set_notif_pending(struct bonding *bond,
> +					  bond_notif_pending_t bit, bool set)
> +{
> +	if (set)
> +		test_and_set_bit(bit, &bond->notif_work_mask);
> +	else
> +		test_and_clear_bit(bit, &bond->notif_work_mask);
> +}

If you do not need the return value of test_and_set_bit() and
test_and_clear_bit(), why are you using them, since they are more
expensive ?

May I suggest instead :


static inline void bond_notif_pending_set(struct bonding *bond,
                                          bond_notif_pending_t bit)
{
	set_bit(bit, &bond->notif_work_mask);
}

static inline void bond_notif_pending_clear(struct bonding *bond,
                                            bond_notif_pending_t bit)
{
	clear_bit(bit, &bond->notif_work_mask);
}
