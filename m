From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Race between suspend and open in network drivers?
Date: Sat, 23 Apr 2005 23:01:12 -0500
Message-ID: <200504232301.12990.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have a question regarding possible race between suspend and open
methods in most network drivers. Consider b44 for example:

static int b44_suspend(struct pci_dev *pdev, pm_message_t state)
{
        struct net_device *dev = pci_get_drvdata(pdev);
        struct b44 *bp = netdev_priv(dev);

        if (!netif_running(dev))
                 return 0;

Why can we just check netif_running and bail out? What stops 2nd CPU
from getting into b44_open right then and set up the device and we'll
get into suspend with device fully set up and DMAing...

Come to think of it it's not even a race since b44_open does not even
check if device is suspended. I must be missing something... Do we rely
on userland being completely stopped while suspending? But what about
suspend to ram (IIRC we don't stop userlan there) or selective suspend? 

Thanks!

-- 
Dmitry
