From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v3.5 18/19] rtlwifi: slight optimization of addr compare
Date: Mon, 6 Jan 2014 15:51:43 -0500
Message-ID: <20140106205143.GH10885@tuxdriver.com>
References: <52BC15EA.2020603@huawei.com>
 <52BC2576.3090601@cogentembedded.com>
 <20140106195302.GF10885@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140106195302.GF10885@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 06, 2014 at 02:53:02PM -0500, John W. Linville wrote:
> On Thu, Dec 26, 2013 at 04:47:50PM +0400, Sergei Shtylyov wrote:
> > Hello.
> > 
> > On 26-12-2013 15:41, Ding Tianhong wrote:
> > 
> > >Use possibly more efficient ether_addr_equal_unaligned
> > >instead of memcmp.
> > 
> > >Cc: Larry Finger <Larry.Finger@lwfinger.net>
> > >Cc: Chaoming Li <chaoming_li@realsil.com.cn>
> > >Cc: John W. Linville <linville@tuxdriver.com>
> > >Cc: linux-wireless@vger.kernel.org
> > >Cc: netdev@vger.kernel.org
> > >Cc: linux-kernel@vger.kernel.org
> > >Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> > >Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> > >---
> > >  drivers/net/wireless/rtlwifi/cam.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > >diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
> > >index 0e510f7..0276153 100644
> > >--- a/drivers/net/wireless/rtlwifi/cam.c
> > >+++ b/drivers/net/wireless/rtlwifi/cam.c
> > [...]
> > >@@ -335,7 +335,7 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
> > >  		addr = rtlpriv->sec.hwsec_cam_sta_addr[i];
> > >  		bitmap = (rtlpriv->sec.hwsec_cam_bitmap) >> i;
> > >  		if (((bitmap & BIT(0)) == BIT(0)) &&
> > >-		    (memcmp(addr, sta_addr, ETH_ALEN) == 0)) {
> > >+		    (ether_addr_equal_unaligned(addr, sta_addr))) {
> > 
> >    It's pointless to enclose function call in parens, again.
> 
> I'll correct that issue when merging the patch.

Well, that was the plan...  But since ether_addr_equal_unaligned
isn't in the wireless trees at the moment, it will have to wait or go
through another tree that has that definition.  Feel free to respin
with the extra parenthesis removed...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
