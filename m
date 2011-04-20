From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] bonding: move processing of recv handlers
 into handle_frame()
Date: Wed, 20 Apr 2011 13:30:44 +0200
Message-ID: <20110420113043.GD2998@psychotron.brq.redhat.com>
References: <1303220896-9092-1-git-send-email-jpirko@redhat.com>
 <1303221752.3480.217.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620Ab1DTLa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 07:30:57 -0400
Content-Disposition: inline
In-Reply-To: <1303221752.3480.217.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 19, 2011 at 04:02:32PM CEST, eric.dumazet@gmail.com wrote:
>Le mardi 19 avril 2011 =E0 15:48 +0200, Jiri Pirko a =E9crit :
>> Since now when bonding uses rx_handler, all traffic going into bond
>> device goes thru bond_handle_frame. So there's no need to go back in=
to
>> bonding code later via ptype handlers. This patch converts
>> original ptype handlers into "bonding receive probes". These functio=
ns
>> are called from bond_handle_frame and they are registered per-mode.
>>=20
>> Note that vlan packets are also handled because they are always unta=
gged
>> thanks to vlan_untag()
>>=20
>> Note that this also allows arpmon for eth-bond-bridge-vlan topology.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>
>
>>  			}
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bon=
ding.h
>> index 6126c6a..85fb822 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -226,6 +226,8 @@ struct bonding {
>>  	struct   slave *primary_slave;
>>  	bool     force_primary;
>>  	s32      slave_cnt; /* never change this value outside the attach/=
detach wrappers */
>> +	void     (*recv_probe)(struct sk_buff *, struct bonding *,
>> +			       struct slave *);
>>  	rwlock_t lock;
>>  	rwlock_t curr_slave_lock;
>>  	s8       kill_timers;
>
>
>Any performance numbers ?

Getting these. (Hitting nasty panic on another machine running pktgen @
vlan dev).

>
>I am asking because recv_probe sits in a often dirtied cache line...
>
>It would be nice to separate rx & tx path needs
>
>
>
