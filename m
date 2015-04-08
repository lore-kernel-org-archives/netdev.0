From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFCv3 2/4] net: Export IGMP/MLD message
	validation code
Date: Tue, 07 Apr 2015 23:22:13 -0400 (EDT)
Message-ID: <20150407.232213.861958959839557793.davem@davemloft.net>
References: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
	<1428436652-4676-3-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	bridge@lists.linux-foundation.org
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1428436652-4676-3-git-send-email-linus.luessing@c0d3.blue>
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
Date: Tue,  7 Apr 2015 21:57:30 +0200

> With this patch, the IGMP and MLD message validation functions are mo=
ved
> from the bridge code to the IPv4/IPv6 multicast files. Some small
> refactoring was done to enhance readibility and to iron out some
> differences in behaviour between the IGMP and MLD parsing code (e.g. =
the
> skb-cloning of MLD messages is now only done if necessary, just like =
the
> IGMP part always did).
> =

> Finally, these IGMP and MLD message validation functions are exported=
 so
> that not only the bridge can use it but batman-adv later, too.

First, you're missing a proper signoff for this patch.

Second, this is going to run into the usual ugly case of how to
deal with the exports when someone wants to build batman-adv
statically into the kernel, yet keep ipv6 modular.

This:

+	depends on !BATMAN_ADV_MCAST || IPV6 || IPV6=3Dn

Doesn't really cut it.  How can a user who made IPV6 modular
and BATMAN_ADV static figure out that he needs to abide by
this convoluted rule just to enable multicasting properly?

Look at the obj-y rules in net/ipv6/Makefile for a better way
to handle this.
