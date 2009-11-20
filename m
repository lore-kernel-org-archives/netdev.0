From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Fri, 20 Nov 2009 06:43:46 +0100
Message-ID: <4B062C92.4000001@gmail.com>
References: <4AF8EBA4.2070102@gmail.com>	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com>	<adaocn8x6j7.fsf@roland-alpha.cisco.com>	<8C10E584257A46DB9A0AD193520CF4A7@amr.corp.intel.com>	<4B0628E0.6000404@gmail.com> <20091119214047.1a966c79@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sean Hefty <sean.hefty@intel.com>,
	"'Roland Dreier'" <rdreier@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Roland Dreier <rolandd@cisco.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma <linux-rdma@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47690 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbZKTFnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 00:43:49 -0500
In-Reply-To: <20091119214047.1a966c79@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Fri, 20 Nov 2009 06:28:00 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> +		read_lock(&dev_base_lock);
>>  		for_each_netdev(&init_net, dev) {
>>  			if (ipv6_chk_addr(&init_net,
>>  					  &((struct sockaddr_in6 *) addr)->sin6_addr,
>> @@ -139,6 +140,7 @@ int rdma_translate_ip(struct sockaddr *addr, str=
uct rdma_dev_addr *dev_addr)
>>  				break;
>>  			}
>>  		}
>> +		read_unlock(&dev_base_lock);
>=20
> what about for_each_netdev_rcu() here instead...
>=20

Yes, in 2.6.33 :)

=46or 2.6.32, we need this patch

Thanks
