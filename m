From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Wed, 21 Jun 2017 12:57:36 +0300
Message-ID: <CAJ3xEMhVdmpiGxBb8r0Sx3g_4ej7uhaCf4+qSi3ObMJ=-4ybXQ@mail.gmail.com>
References: <20170620130006.307-1-Yuval.Mintz@cavium.com> <20170620.123551.765657502957371421.davem@davemloft.net>
 <CAJ3xEMjyHidoAV9_VPkTM9dPdaXRFt8LmpcV_5iEvYEB+ujSmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMjyHidoAV9_VPkTM9dPdaXRFt8LmpcV_5iEvYEB+ujSmA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2017 at 12:56 PM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Jun 20, 2017 at 7:35 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>> Date: Tue, 20 Jun 2017 15:59:59 +0300
>>
>>> Please consider applying this series to `net-next'.
>>
>> Series applied, thanks.

Yuval,

It's broke my build

In file included from drivers/net/ethernet/qlogic/qede/qede.h:43,
                 from drivers/net/ethernet/qlogic/qede/qede_ethtool.c:41:
./include/linux/qed/qede_rdma.h:85: error: expected identifier or '('
before '{' token
In file included from drivers/net/ethernet/qlogic/qede/qede.h:43,
                 from drivers/net/ethernet/qlogic/qede/qede_dcbnl.c:13:
./include/linux/qed/qede_rdma.h:85: error: expected identifier or '('
before '{' token
make[5]: *** [drivers/net/ethernet/qlogic/qede/qede_dcbnl.o] Error 1

here's the fix

diff --git a/include/linux/qed/qede_rdma.h b/include/linux/qed/qede_rdma.h
index 1348a16..9904617 100644
--- a/include/linux/qed/qede_rdma.h
+++ b/include/linux/qed/qede_rdma.h
@@ -81,7 +81,7 @@ void qede_rdma_dev_remove(struct qede_dev *dev);
 void qede_rdma_event_changeaddr(struct qede_dev *edr);

 #else
-static inline int qede_rdma_dev_add(struct qede_dev *dev);
+static inline int qede_rdma_dev_add(struct qede_dev *dev)
 {
        return 0;
 }
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
