From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 kernel oops when setting flow control while interface is
 down (2.6.10)
Date: Thu, 10 Mar 2005 19:45:21 -0800
Message-ID: <20050310194521.317474c7.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3DCE@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: d.willmann@tu-bs.de, netdev@oss.sgi.com, jluebbe@lasnet.de,
        davem@redhat.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3DCE@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Feb 2005 09:26:25 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> I think it is better to just set the PAUSE flags and return 0 if
> !netif_running(). This way, the settings will take effect when the device is
> subsequently brought up.

Then arguably we should do the same for link settings too.
His patch exactly makes pause parameter setting behave
the same as we currently do for link settings, if the device
is down or in low power PHY mode, we -EAGAIN error out.

We have to decide driver-wide how we're going to handle this
situation.
