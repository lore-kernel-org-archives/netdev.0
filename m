From: vkochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 2/3] ip-link: fix and extend documentation
Date: Thu, 13 Aug 2015 09:28:10 +0300
Message-ID: <20150813062810.GA13296@vkochan>
References: <1439409848-26464-1-git-send-email-pavlix@pavlix.net>
 <1439409848-26464-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Phil Sutter <psutter@redhat.com>,
	Pavel =?utf-8?Q?=C5=A0imerda?= <psimerda@redhat.com>
To: Pavel =?utf-8?Q?=C5=A0imerda?= <pavlix@pavlix.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33648 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbbHMG2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 02:28:12 -0400
Received: by lbbsx3 with SMTP id sx3so21555965lbb.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 23:28:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1439409848-26464-2-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 10:04:07PM +0200, Pavel =C5=A0imerda wrote:
> From: Pavel =C5=A0imerda <psimerda@redhat.com>
>=20
>  * Add `can` to list of supported link types
>  * Document `addrgenmode`
>  * Document `link-netnsid`
>  * Document VLAN link type
>  * Improve VXLAN link type documentation
>     - Fix VXLAN srcport/dstport docs
>     - Document `udpcsum`, `udp6zerocsumtx` and `udp6zerocsumrx`
> ---
>  man/man8/ip-link.8.in | 112 ++++++++++++++++++++++++++++++++++++++++=
++++++++--
>  1 file changed, 108 insertions(+), 4 deletions(-)
>=20
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 372e6c6..9ff9a23 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -143,9 +143,13 @@ ip-link \- network device configuration
>  ] |
>  .br
>  .B master
> -.IR DEVICE
> +.IR DEVICE " |"
>  .br
> -.B nomaster
> +.B nomaster " |"
> +.br
> +.B addrgenmode { eui64 | none }
> +.br
> +.B link-netnsid ID
>  .BR " }"
> =20
> =20
> @@ -185,6 +189,8 @@ Link types:
>  .sp
>  .B bond
>  - Bonding device
> +.B can
> +- Controller Area Network interface
>  .sp
>  .B dummy
>  - Dummy network interface
> @@ -266,6 +272,66 @@ specifies the number of receive queues for new d=
evice.
>  specifies the desired index of the new virtual device. The link crea=
tion fails, if the index is busy.
> =20
>  .TP
> +VLAN Type Support
> +For a link of type
> +.I VLAN
> +the following additional arguments are supported:
> +
> +.BI "ip link add
> +.BI link " DEVICE "
> +.BI name " NAME "
> +.BI type " vlan "
> +.R " [ "
> +.BI protocol " VLAN_PROTO "
> +.R " ] "
> +.BI id " VLANID "
> +.R " [ "
> +.BR reorder_hdr " { " on " | " off " } "
> +.R " ] "
> +.R " [ "
> +.BR gvrp " { " on " | " off " } "
> +.R " ] "
> +.R " [ "
> +.BR mvrp " { " on " | " off " } "
> +.R " ] "
> +.R " [ "
> +.BR loose_binding " { " on " | " off " } "
> +.R " ] "
> +.R " [ "
> +.BI ingress-qos-map " QOS-MAP "
> +.R " ] "
> +.R " [ "
> +.BI egress-qos-map " QOS-MAP "
> +.R " ] "
> +
> +.in +8
> +.sp
> +.BI protocol " VLAN_PROTO "
> +- either 802.1Q or 802.1ad.
> +
> +.BI id " VLANID "
> +- specifies the VLAN Identifer to use. Note that numbers with a lead=
ing " 0 " or " 0x " are interpreted as octal or hexadeimal, respectivel=
y.
> +
> +.BR reorder_hdr " { " on " | " off " } "
> +- specifies whether ethernet headers are reordered or not.
May be it should have more detailed explanation like that this feature =
is ON by default and what it affects on ?

> +
> +.BR gvrp " { " on " | " off " } "
> +- specifies whether this VLAN should be registered using GARP VLAN R=
egistration Protocol.
> +
> +.BR mvrp " { " on " | " off " } "
> +- specifies whether this VLAN should be registered using Multiple VL=
AN Registration Protocol.
> +
> +.BR loose_binding " { " on " | " off " } "
> +- specifies whether the VLAN device state is bound to the physical d=
evice state.
May be add some little explanation that it means that if physical devic=
e goes DOWN then the vlan device does the same ?

> +
> +.BI ingress-qos-map " QOS-MAP "
> +- defines a mapping between priority code points on incoming frames.=
  The format is FROM:TO with multiple mappings separated by spaces.
Would it be useful if to add here explanation that under priority it me=
ans skb->priority and may be some example how it can be set by iptable =
CLASSIFY ?
> +
> +.BI egress-qos-map " QOS-MAP "
> +- the same as ingress-qos-map but for outgoing frames.
> +.in -8
> +
> +.TP
>  VXLAN Type Support
>  For a link of type
>  .I VXLAN
> @@ -284,7 +350,9 @@ the following additional arguments are supported:
>  .R " ] [ "
>  .BI tos " TOS "
>  .R " ] [ "
> -.BI port " MIN MAX "
> +.BI dstport " PORT "
> +.R " ] [ "
> +.BI srcport " MIN MAX "
>  .R " ] [ "
>  .I "[no]learning "
>  .R " ] [ "
> @@ -296,6 +364,12 @@ the following additional arguments are supported=
:
>  .R " ] [ "
>  .I "[no]l3miss "
>  .R " ] [ "
> +.I "[no]udpcsum "
> +.R " ] [ "
> +.I "[no]udp6zerocsumtx "
> +.R " ] [ "
> +.I "[no]udp6zerocsumrx "
> +.R " ] [ "
>  .BI ageing " SECONDS "
>  .R " ] [ "
>  .BI maxaddress " NUMBER "
> @@ -340,7 +414,11 @@ parameter.
>  - specifies the TOS value to use in outgoing packets.
> =20
>  .sp
> -.BI port " MIN MAX"
> +.BI dstport " PORT"
> +- specifies the UDP destination port to communicate to the remote VX=
LAN tunnel endpoint.
> +
> +.sp
> +.BI srcport " MIN MAX"
>  - specifies the range of port numbers to use as UDP
>  source ports to communicate to the remote VXLAN tunnel endpoint.
> =20
> @@ -366,6 +444,18 @@ are entered into the VXLAN device forwarding dat=
abase.
>  - specifies if netlink IP ADDR miss notifications are generated.
> =20
>  .sp
> +.I [no]udpcsum
> +- specifies if UDP checksum is filled in
> +
> +.sp
> +.I [no]udp6zerocsumtx
> +- specifies if UDP checksum is filled in
> +
> +.sp
> +.I [no]udp6zerocsumrx
> +- specifies if UDP checksum is received
> +
> +.sp
>  .BI ageing " SECONDS"
>  - specifies the lifetime in seconds of FDB entries learnt by the ker=
nel.
> =20
> @@ -751,6 +841,12 @@ tool can be used. But it allows to change networ=
k namespace only for physical de
>  give the device a symbolic name for easy reference.
> =20
>  .TP
> +.BI group " GROUP"
> +specify the group the device belongs to.
> +The available groups are listed in file
> +.BR "@SYSCONFDIR@/group" .
> +
> +.TP
>  .BI vf " NUM"
>  specify a Virtual Function device to be configured. The associated P=
=46 device
>  must be specified using the
> @@ -829,6 +925,14 @@ set master device of the device (enslave device)=
=2E
>  .BI nomaster
>  unset master device of the device (release device).
> =20
> +.TP
> +.BR "addrgenmode eui64 " or " addrgenmode none"
> +set IPv6 address generation mode
> +
> +.TP
> +.BR "link-netnsid "
> +set peer netnsid for a cross-netns interface
> +
>  .PP
>  .B Warning:
>  If multiple parameter changes are requested,
> --=20
> 2.4.1
>=20

I just added my IMHOs, so please ignore them if you think they are usel=
ess.

Regards,
