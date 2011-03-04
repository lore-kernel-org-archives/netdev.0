From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2011-02-22
Date: Fri, 4 Mar 2011 13:40:50 -0500
Message-ID: <20110304184050.GC9866@tuxdriver.com>
References: <20110222215229.GJ12153@tuxdriver.com>
 <4D706C2E.40307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Shan Wei <shanwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D706C2E.40307-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 04, 2011 at 12:35:58PM +0800, Shan Wei wrote:
> John W. Linville wrote, at 02/23/2011 05:52 AM:
> > Please let me know if there are problems!
> 
> Fail to compile with attached config under net-next tree.
>  
> ======Error Begin================================================================
> drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_sw_chnl':
> /data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:803: multiple definition of `rtl92c_phy_sw_chnl'
> drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:803: first defined here
> drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_fill_h2c_cmd':

This is already fixed in wireless-next-2.6:

commit 1472d3a87586eb7529d1d85f7c888055650b7208
Author: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date:   Wed Feb 23 10:24:58 2011 -0600

    rtlwifi: rtl8192ce: rtl8192cu: Fix multiple def errors for allyesconfig buil
    
    As noted by Stephan Rothwell, an allyesconfig build fails since rtl8192cu
    was merged with failures such as:
    
    drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_s
    (.opd+0xf30): multiple definition of `rtl92c_phy_sw_chnl'
    drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:(.opd+0xb70): first define
    drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_fill_
    (.opd+0x288): multiple definition of `rtl92c_fill_h2c_cmd'
    drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:(.opd+0x288): first define
    
    These are caused because the code shared between rtl8192ce and rtl8192cu
    is included in both drivers. This has been fixed by creating a new modue tha
    contains the shared code.
    
    Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

It will be in my next pull request to Dave.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
