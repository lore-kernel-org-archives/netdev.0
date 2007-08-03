From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 1/1] lro: Generic Large Receive Offload for TCP traffic
Date: Fri, 3 Aug 2007 15:41:50 +0200
Message-ID: <20070803134150.GH19344@lazybastard.org>
References: <200708031441.20632.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762174AbXHCNp5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708031441.20632.ossthema@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 3 August 2007 14:41:19 +0200, Jan-Bernd Themann wrote:
>=20
> This patch provides generic Large Receive Offload (LRO) functionality
> for IPv4/TCP traffic.
>=20
> LRO combines received tcp packets to a single larger tcp packet and=20
> passes them then to the network stack in order to increase performanc=
e
> (throughput). The interface supports two modes: Drivers can either pa=
ss
> SKBs or fragment lists to the LRO engine.=20

Maybe this is a stupid question, but why is LRO done at the device
driver level?

If it is a unversal performance benefit, I would have expected it to be
done generically, i.e. have all packets moved into network layer pass
through LRO instead.

> +void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
> +		   struct iphdr *iph, struct tcphdr *tcph);

In particular this bit looks like it should be driven by a timeout,
which would be settable via /proc/sys/net/core/lro_timeout or similar.

J=C3=B6rn

--=20
Rules of Optimization:
Rule 1: Don't do it.
Rule 2 (for experts only): Don't do it yet.
-- M.A. Jackson
