From: nickcave <nickcave.zhang@gmail.com>
Subject: problem when a ipsec output packet re-routing in ip6_route_me_harder
Date: Thu, 8 May 2014 13:24:58 +0800
Message-ID: <CAF-n9KNFWmEtKw1ufAFX-ec_4THSGtAuNpvGL8fSQbatZBuwDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f194.google.com ([209.85.128.194]:59532 "EHLO
	mail-ve0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaEHFY7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 01:24:59 -0400
Received: by mail-ve0-f194.google.com with SMTP id db11so549358veb.9
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 22:24:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All:

I found in some case a packet match IPSEC rule will be send out in plai=
ntext.

If a output ipv6 packet match a ipsec rule and the dst be set to
xfrm_output correct,
 but there is a netfilter mangle table rule also matched the rule
which set the mark value to 0x01 ,
and then ,in ip6t_mangle_out ,when ip6t_do_table finished, the mark
value changed, and the packet
need routing by ip6_route_me_harder , the packet will be decode by

 ip6_route_me_harder=E2=80=94>xfrm_decode_session->_decode_session6  th=
e
function get nexthdr from cb , I found the cb only be set when it's a
incoming packet, so in this case , I got a error nexthdr  value. It's
caused the xfrm_lookup failure,and the packet be sendout in plaintext.
    u8 nexthdr =3D nh[IP6CB(skb)->nhoff]; //in my case, the nexthdr is =
always 96

I think it a kernel bug.Did anyone met the same issue?

Best Regards
Hui Zhang
