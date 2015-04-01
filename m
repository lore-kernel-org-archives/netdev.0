From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFCv2 3/4] batman-adv: Forward IGMP/MLD reports
 to selected querier (only)
Date: Wed, 01 Apr 2015 13:44:31 -0400 (EDT)
Message-ID: <20150401.134431.1653220163353310062.davem@davemloft.net>
References: <1427875479-9240-1-git-send-email-linus.luessing@c0d3.blue>
	<1427875479-9240-4-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	bridge@lists.linux-foundation.org
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1427875479-9240-4-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Wed,  1 Apr 2015 10:04:38 +0200

> With this patch IGMP or MLD reports are only forwarded to the selecte=
d
> IGMP/MLD querier as RFC4541 suggests. This is necessary to avoid
> multicast packet loss in bridged scenarios later:
> =

> An IGMPv2/MLDv1 querier does not actively join the multicast group th=
e
> reports are sent to. Because of this, this leads to snooping
> bridges/switches not being able to learn of multicast listeners in th=
e
> mesh and wrongly shutting down ports for multicast traffic to the mes=
h.

There is no way this is going to work.

First of all, you have no proper Kconfig dependencies upon IPV6, yet
you are calling these newly exported ipv6 multicast interfaces
unconditionally.

Even once you resolve that, you are going to run into problems in
situations where BATMAN_ADV=3Dy and IPV6=3Dm, for example.
