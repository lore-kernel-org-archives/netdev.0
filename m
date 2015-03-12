From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next 1/4] bonding: Handle notifications during
 work-queue processing gracefully
Date: Thu, 12 Mar 2015 11:34:33 -0700
Message-ID: <CAHo-Ooz4Lb3uO_TA0bK8QOrXg4nBZQeAhvpAH9Av1hqma9WS_Q@mail.gmail.com>
References: <1426139676-27124-1-git-send-email-maheshb@google.com>
	<1426152704.11398.149.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:44285 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbbCLSee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:34:34 -0400
Received: by lbvn10 with SMTP id n10so17944462lbv.11
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 11:34:33 -0700 (PDT)
In-Reply-To: <1426152704.11398.149.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_get_notif_pending(struct bonding *bond,
                                         bond_notif_pending_t bit)
{
       return !!test_bit(bit, &bond->notif_work_mask);
}

imho this should use test_and_clear_bit, and you should actually never
use the pending_clear, only have pending_set
