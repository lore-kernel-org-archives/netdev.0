From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v2 02/17] net: Combine GENEVE and VXLAN port
 notifiers into single functions
Date: Thu, 16 Jun 2016 08:23:01 -0700
Message-ID: <CAKgT0Ues0jX2u8+2pf4Sc0+7=ES5OhLg_=to6Nr_X4+Vt9OnBA@mail.gmail.com>
References: <20160615220449.15575.17031.stgit@localhost.localdomain>
 <20160615220728.15575.62132.stgit@localhost.localdomain> <CAEh+42i8y70XsuuXs1+LYVxRomvJZUEWg6KhonoxvNqaYe9dtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Michael Chan <michael.chan@broadcom.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33029 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162AbcFPPXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 11:23:03 -0400
Received: by mail-io0-f194.google.com with SMTP id 5so7208079ioy.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 08:23:02 -0700 (PDT)
In-Reply-To: <CAEh+42i8y70XsuuXs1+LYVxRomvJZUEWg6KhonoxvNqaYe9dtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 4:50 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Wed, Jun 15, 2016 at 3:07 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index e5e33cd01082..d12ee3a92fb5 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>>  static void geneve_notify_del_rx_port(struct geneve_sock *gs)
>>  {
>> -       struct net_device *dev;
>> -       struct sock *sk = gs->sock->sk;
>> -       struct net *net = sock_net(sk);
>> -       sa_family_t sa_family = geneve_get_sk_family(gs);
>> -       __be16 port = inet_sk(sk)->inet_sport;
>> -
>> -       rcu_read_lock();
>> -       for_each_netdev_rcu(net, dev) {
>> -               if (dev->netdev_ops->ndo_del_geneve_port)
>> -                       dev->netdev_ops->ndo_del_geneve_port(dev, sa_family,
>> -                                                            port);
>> -       }
>> -
>> -       rcu_read_unlock();
>> +       udp_tunnel_notify_add_rx_port(gs->sock, UDP_TUNNEL_TYPE_GENEVE);
>>  }
>
> Looks like a typo here - calling add instead of delete.

Yeah.  I had a few other spots that occurred.  I thought I had caught
them all before submitting but I guess not.  I will fix that for v3.

Thanks.

- Alex
