From: andrew hendry <andrew.hendry@gmail.com>
Subject: tuntap with tun_no_pi and X25 question
Date: Wed, 24 Feb 2010 22:52:27 +1100
Message-ID: <d45a3acc1002240352r43e546c7x4a40aa7d8e187369@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setting up tun using X25, I can read X25 from the tun but cannot write
to it, hitting this -EINVAL on write.

/* Get packet from user space buffer */
static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
                                       const struct iovec *iv, size_t count,
                                       int noblock)
{

....
       case TUN_TUN_DEV:
                if (tun->flags & TUN_NO_PI) {
                        switch (skb->data[0] & 0xf0) {
                        case 0x40:
                                pi.proto = htons(ETH_P_IP);
                                break;
                        case 0x60:
                                pi.proto = htons(ETH_P_IPV6);
                                break;
                        default:
                                tun->dev->stats.rx_dropped++;
                                kfree_skb(skb);
                                return -EINVAL;
                        }
                }
....

The 0x40 and 0x60 comes from the first byte of the IP which has the
version there?
With X.25 the first byte changes depending on the call sequence, so it
cant be detected and set in the same way.

Is there a way to for a combination of TUNSETIFF with IFF_TUN |
IFF_NO_PI and TUNSETLINK with ARPHRD_X25 to work?
Probably all the non IP type protocols in if_arp.h have the same issue
with IFF_NO_PI?

thanks,
Andrew
