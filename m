From: Andy Johnson <johnsonzjo@gmail.com>
Subject: skb_is_gso() in ip_forward.c
Date: Wed, 12 Jun 2013 16:48:03 +0300
Message-ID: <CAF0Lin26AEdtz+Ui=LQ-T285OpbgfnsN3ofdmvbwavM9eQjBCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:43095 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab3FLNsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 09:48:04 -0400
Received: by mail-wg0-f51.google.com with SMTP id e11so2764073wgh.6
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 06:48:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would appreciate if someone can explain the following :

We have this in net/ipv4/ip_forward():
...
 if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
  ...
  icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
                            htonl(dst_mtu(&rt->dst)));
                  goto drop;
          }
...

As I understand, it the traffic is GSO and the length of the skb is
larger than the MTU, we don't send destination unreachable ICMP and
we continue with forwarding the packet. My qustion is: why is it so ?
is it because when working with GSO the size of skb->len is not the
size of the packet which is sent on the wire ? The what does it
represent when the traffic is GSO ?
I would appreaicate if someone can elaborate on this.


Best
Andy
