From: Du Fan <fengyuleidian0615@gmail.com>
Subject: [Discussion] About over-MTU-sized skb in virtualized env
Date: Wed, 03 Dec 2014 14:39:37 +0800
Message-ID: <547EB029.5010102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, "Michael S. Tsirkin" <mst@redhat.com>,
	Jesse Gross <jesse@nicira.com>,
	Flavio Leitner <fbl@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>, pshelar@nicira.com,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"Du, Fan" <fan.du@intel.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:58232 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaLCGmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 01:42:20 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so15149866pad.37
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 22:42:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for resend this mail, because my company email is rejected by net=
dev.


Hi Florian

  214 static int ip_finish_output_gso(struct sk_buff *skb)
  215 {
  216     netdev_features_t features;
  217     struct sk_buff *segs;
  218     int ret =3D 0;
  219
  220     /* common case: locally created skb or seglen is <=3D mtu */
  221     if (((IPCB(skb)->flags & IPSKB_FORWARDED) =3D=3D 0) ||
  222           skb_gso_network_seglen(skb) <=3D ip_skb_dst_mtu(skb))
  223         return ip_finish_output2(skb);

Could you please state _concrete_ reason why locally created skb
length is =EF=BC=BFalways=EF=BC=BF fitting into MTU size? or why we nee=
ds this
checking.
Especially in below scenario:
http://docs.openstack.org/admin-guide-cloud/content/figures/14/a/a/comm=
on/figures/under-the-hood-scenario-1-ovs-compute.png

As many people have discuss it in this thread:
http://marc.info/?t=3D141715669700004&r=3D1&w=3D2
