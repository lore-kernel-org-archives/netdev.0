From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 11:11:22 +0100
Message-ID: <1300702282.2884.23.camel@edumazet-laptop>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
	 <1300699294.10934.63.camel@firesoul.comx.local>
	 <1300700708.2884.10.camel@edumazet-laptop>
	 <1300701232.2884.12.camel@edumazet-laptop>
	 <1300701852.10934.67.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46948 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab1CUKL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 06:11:27 -0400
Received: by fxm17 with SMTP id 17so5311784fxm.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 03:11:25 -0700 (PDT)
In-Reply-To: <1300701852.10934.67.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 mars 2011 =C3=A0 11:04 +0100, Jesper Dangaard Brouer a =C3=A9=
crit :
> On Mon, 2011-03-21 at 10:53 +0100, Eric Dumazet wrote:
> > Couly you please send us the result of "ethtool -k eth01" to make s=
ure
> > its the problem ?
>=20
> prod server:
>=20
> albpd4:~# ethtool -k eth01
> Offload parameters for eth01:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: on
> ntuple-filters: off
> receive-hashing: off
>=20
> pre-prod server:
>=20
> albpd1:~# ethtool -k eth01
> Offload parameters for eth01:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
>=20
> Hmm... notice how the large-receive-offload (LRO) is different on the
> two machines.
>=20
> I cannot disable LRO with userspace ethtool:
>=20
> albpd4:~# ethtool -K eth01 lro off
> Cannot set large receive offload settings: Invalid argument
>=20

Sure, this is the problem. Still your ethtool dont give us the needed
info ;)

I suspect it is :

rx-vlan-offload: off
tx-vlan-offload: on

But would like a confirmation of this ;)

# ethtool -V | head -n 1
ethtool version 2.6.37

# ethtool --version
ethtool version 2.6.37


