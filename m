From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [PATCH] make tg3 NAPI support configurable
Date: Tue, 13 Jan 2004 16:23:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229CE5@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Greg Banks" <gnb@melbourne.sgi.com>, "David S. Miller" <davem@redhat.com>,
        "Linux Network Development list" <netdev@oss.sgi.com>,
        <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: "Robert Olsson" <Robert.Olsson@data.slu.se>,
        "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I was thinking of a variant JC [jchapman@katalix.com] 
> mentioned on this list some time ago. He also sent me
> the patch for e1000. A test and the patch is below.

JC contributed almost the exact patch for the e100 rewrite and it did
help Tx, but I don't remember how much.  JC, do you remember?  Here is
the snippet:

static int e100_poll(struct net_device *netdev, int *budget)
{
        struct nic *nic = netdev->priv;
        unsigned int work_to_do = min(netdev->quota, *budget);
        unsigned int work_done = 0;
        int tx_cleaned;

        e100_rx_clean(nic, &work_done, work_to_do);
        tx_cleaned = e100_tx_clean(nic);

        /* If no Rx and Tx cleanup work was done, exit polling mode. */
        if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev))
{
                netif_rx_complete(netdev);
                e100_enable_irq(nic);
                return 0;
        }

        *budget -= work_done;
        netdev->quota -= work_done;

        return 1;
}
