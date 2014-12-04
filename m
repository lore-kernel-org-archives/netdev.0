From: Du Fan <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Thu, 04 Dec 2014 15:48:46 +0800
Message-ID: <548011DE.4000208@gmail.com>
References: <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home> <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com> <20141202174158.GB9457@casper.infradead.org> <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com> <20141203090339.GA9299@redhat.com> <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com> <20141203183859.GB16447@redhat.com> <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com> <20141203220244.GA8822@casper.infradead.org> <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, "Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>, Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33808 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbaLDHvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 02:51:32 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so17605746pab.0
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 23:51:31 -0800 (PST)
In-Reply-To: <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B412=E6=9C=8804=E6=97=A5 06:51, Jesse Gross =E5=86=
=99=E9=81=93:
> My proposal would be something like this:
>   * For L2, reduce the VM MTU to the lowest common denominator on the=
 segment.
>   * For L3, use path MTU discovery or fragment inner packet (i.e.
> normal routing behavior).
>   * As a last resort (such as if using an old version of virtio in th=
e
> guest), fragment the tunnel packet.

After some investigation on OpenvSwitch package, it seems before this
commit: 06021dcb "datapath: compat: Fix compilation 3.11" OpenvSwitch
package is doing GSO on its own.

rpl_ip_local_out
   -> tnl_skb_gso_segment
       ^^^^^^^^^^^^^^^
          Perform GSO  in above function
     -> ip_local_out
           .
           .
         -> ip_finish_output

Which means, when over-MTU-sized skb enter ip_local_out, it's not a gso
type skb, so the stack perform ip fragmentation, and send them out.
So, over-MTU-sized skb did travel through stack into outside.

Why not dropping such OpenvSwitch level GSO operation after 3.10?



--=20
No zuo no die but I have to try.
