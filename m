From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 16:31:45 +0100
Message-ID: <1286379105.2371.15.camel@achroite.uk.solarflarecom.com>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
	 <1286256926.2457.2.camel@edumazet-laptop>  <4CAB4D8F.8080108@intel.com>
	 <1286296476.2307.5.camel@achroite.uk.solarflarecom.com>
	 <4CAB6447.6040407@intel.com>  <4CAC8D11.2060604@intel.com>
	 <1286377633.2371.11.camel@achroite.uk.solarflarecom.com>
	 <1286378626.9417.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36697 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759066Ab0JFPbs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 11:31:48 -0400
In-Reply-To: <1286378626.9417.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-06 at 17:23 +0200, Eric Dumazet wrote:
> Le mercredi 06 octobre 2010 =C3=A0 16:07 +0100, Ben Hutchings a =C3=A9=
crit :
>=20
> > The waste of memory is minimal now that we only allocate kobjects f=
or
> > real_num_rx_queues.
>=20
> Thats strange, here with tg3 (and mono queue device) :
>=20
> 0a:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S
> Gigabit Ethernet (rev a3)
>=20
> grep . /sys/class/net/eth2/queues/rx-*/rps_cpus
> /sys/class/net/eth2/queues/rx-0/rps_cpus:00000000
> /sys/class/net/eth2/queues/rx-1/rps_cpus:00000000
> /sys/class/net/eth2/queues/rx-2/rps_cpus:00000000
> /sys/class/net/eth2/queues/rx-3/rps_cpus:00000000
> /sys/class/net/eth2/queues/rx-4/rps_cpus:00000000

It looks like I missed a necessary call to
netif_set_real_num_rx_queues() in tg3.  I suggest that Matt should chec=
k
and correct this since I got the numbers wrong last time.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

