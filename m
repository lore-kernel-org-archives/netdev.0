From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Tue, 4 Oct 2016 18:02:17 -0400
Message-ID: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

kernel 4.8 with ulogd-2.0.5- IPs are no longer logged:

Oct  4 17:51:30 atom INPUT_BLOCK IN=eth1 OUT=
MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
TTL=0 ID=0 PROTO=0 MARK=0
Oct  4 17:51:31 atom INPUT_BLOCK IN=eth1 OUT=
MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
TTL=0 ID=0 PROTO=0 MARK=0
Oct  4 17:51:32 atom INPUT_BLOCK IN=eth1 OUT=
MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
TTL=0 ID=0 PROTO=0 MARK=0

(reboot back to kernel 4.7, works fine)

kernel 4.7 with ulogd-2.0.5:
Oct  4 17:56:44 atom INPUT_BLOCK IN=eth1 OUT=
MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 SRC=74.125.22.125
DST=1.2.3.4 LEN=397 TOS=00 PREC=0x00 TTL=48 ID=58093 PROTO=TCP
SPT=5222 DPT=19804 SEQ=2032644254 ACK=2273184383 WINDOW=55272 ACK PSH
URGP=0 MARK=0
Oct  4 17:56:45 atom INPUT_BLOCK IN=eth1 OUT=
MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 SRC=74.125.22.125
DST=1.2.3.4 LEN=397 TOS=00 PREC=0x00 TTL=48 ID=58725 PROTO=TCP
SPT=5222 DPT=19804 SEQ=2032644254 ACK=2273184383 WINDOW=55272 ACK PSH
URGP=0 MARK=0

Looks like there were some changes in the 4.8 kernel regarding ulogd,
has anyone else run into this problem?

                } ulog;
+               if ((li->u.ulog.flags & NF_LOG_F_COPY_LEN) &&
+                   (li->u.ulog.copy_len < data_len))
+                       data_len = li->u.ulog.copy_len;
                li->u.ulog.group = ntohs(nla_get_be16(tb[NFTA_LOG_GROUP]));
+                       li->u.ulog.flags |= NF_LOG_F_COPY_LEN;
                        li->u.ulog.copy_len =
                if (nla_put_be16(skb, NFTA_LOG_GROUP, htons(li->u.ulog.group)))
-               if (li->u.ulog.copy_len) {
+               if (li->u.ulog.flags & NF_LOG_F_COPY_LEN) {
                                         htonl(li->u.ulog.copy_len)))
        li.u.ulog.group      = info->group;
        li.u.ulog.qthreshold = info->threshold;
+               li.u.ulog.flags |= NF_LOG_F_COPY_LEN;

Thanks,

Justin.
