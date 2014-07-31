From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] linux-wpan-next: lowpan_rcv -
 skb is freed within function and fix return values.
Date: Thu, 31 Jul 2014 16:07:53 +0200
Message-ID: <20140731140751.GA10599@omega>
References: <1406732105-17500-1-git-send-email-martin.townsend@xsilon.com>
	<C8606BA6-2918-4313-BEC5-FC3A377DE347@holtmann.org>
	<20140730182738.GA21664@omega>
	<362B23B3-72BB-4E0E-9E06-ABD19C1F2BEF@holtmann.org>
	<20140731135945.GB17560@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org Wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140731135945.GB17560-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jul 31, 2014 at 09:59:46AM -0400, John W. Linville wrote:
> On Wed, Jul 30, 2014 at 11:32:16AM -0700, Marcel Holtmann wrote:
> > Hi Alex,
> > 
> > >>> Currently it is up to the functions below lowpan_rcv to free the skb on error
> > >>>   conditions.  This patch now removes all the UAPI error codes and process data
> > >>>   now returns -1 if there is a problem.  In this scenario lowpan_rcv will free
> > >>>   the skb and return NET_RX_DROP.  This also fixes the problem where
> > >>>   NET_RX_SUCCESS is returned on error
> > >>> 
> > >>> Martin Townsend (2):
> > >>> Remove dev parameter from skb_delivery_cb in 6lowpan.
> > >>> Change lowpan_rcv so skb is freed within function and fix return
> > >>>   values.
> > >>> 
> > >>> include/net/6lowpan.h         |  4 ++--
> > >>> net/6lowpan/iphc.c            | 37 ++++++++++++++++++------------------
> > >>> net/bluetooth/6lowpan.c       | 21 ++++++++++-----------
> > >>> net/ieee802154/6lowpan_rtnl.c | 44 +++++++++++++++++++++----------------------
> > >>> 4 files changed, 52 insertions(+), 54 deletions(-)
> > >> 
> > >> I can not take these patches at this point.
> > >> 
> > >> checking file net/ieee802154/6lowpan_rtnl.c
> > >> Hunk #1 FAILED at 143.
> > >> Hunk #2 succeeded at 480 (offset -4 lines).
> > >> 1 out of 2 hunks FAILED
> > >> 
> > >> We need to get the IEEE 802.15.4 changes merged through John's wireless-next tree. IEEE 802.15.4 going straight into net-next and Bluetooth going into wireless-next will not work out smoothly when both technologies are now utilizing 6LoWPAN and we are heavily working on 6LoWPAN.
> > >> 
> > > 
> > > I already told Martin that these patches should be based on bluetooth
> > > (better bluetooth-next, 802.15.4 hasn't a real stable strategie and there
> > > are also some known other issues in the current implementation). I don't
> > > think that the current implementation is used in a real environment.
> > > 
> > > I get this patch-series in a resend of this series, after Martin
> > > subscribed the linux-zigbee-devel mailinglist, then I told Martin that I
> > > need some time for review and he want to resend them tomorrow or friday.
> > > The resend should based on bluetooth-next then, if this is okay for you.
> > 
> > if patches are based on bluetooth-next, then we have no problem here. I can easily merge them.
> 
> Does that resolve it?  That probably won't make 3.17, fwiw...
> 

there are some issues on this patch series. Martin need to work on and
resend them as v2.

I told about the issues on an another thread which should be the same series.
I don't get exactly this patch series, I think Marcel add me in CC later.

So it needs some time anyway. Thanks.

- Alex

------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
