From: Milad khajavi <khajavi@gmail.com>
Subject: =?UTF-8?Q?How_to_filter_and_intercept_packets_by_using_net=5Fdev?=
	=?UTF-8?Q?=5Fadd_api=3F=E2=80=8F?=
Date: Tue, 15 Oct 2013 15:34:17 +0330
Message-ID: <CAJUHuJpjdRLAPBA1TpSG5=gySDyaaKG+CU-v=h3h+davru+pMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:49857 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506Ab3JOMEt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 08:04:49 -0400
Received: by mail-la0-f53.google.com with SMTP id el20so6655170lab.40
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 05:04:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm writing ethernet network driver for linux. I want to receive
packets, edit and resend them. I know how to edit the packet in
packet_interceptor function, but how can I drop incoming packets in
this function??

Yesterday I've asked this question in stackoverflow [1], but since
now, no one reply that.

#include <linux/netdevice.h>
#include <linux/skbuff.h>
#include <linux/ip.h>

struct packet_type my_proto;

int packet_interceptor(struct sk_buff *skb,
    struct net_device *dev,
    struct packet_type *pt,
    struct net_device *orig_dev) {

    //// I don't want certain packets go to upper in net_devices for
further processing.
    //// How can I drop sk_buff here?!

  return 0;
}

static int hello_init( void ) {
    printk(KERN_INFO "Hello, world!\n");

    my_proto.type =3D htons(ETH_P_ALL);
    my_proto.dev =3D NULL;
    my_proto.func =3D packet_interceptor;

    dev_add_pack(&my_proto);
    return 0;
}

static void hello_exit(void) {
  dev_remove_pack(&my_proto);
  printk(KERN_INFO "Bye, world\n");
}

module_init(hello_init);
module_exit(hello_exit);

[1] - http://stackoverflow.com/questions/19342252/how-to-filter-and-int=
ercept-linux-packets-by-using-net-dev-add-api

--=20
=EF=BB=BF=EF=BB=BFMil=C4=81d Kh=C4=81javi
http://blog.khajavi.ir
Having the source means you can do it yourself.
I tried to change the world, but I couldn=E2=80=99t find the source cod=
e.
