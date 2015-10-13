From: Kenneth Lee <Kenneth-Lee-2012@foxmail.com>
Subject: Re: Fwd: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once
 HANDEL_TX_MSG macro
Date: Tue, 13 Oct 2015 21:27:12 +0800
Message-ID: <20151013132712.GA3310@kllt-03>
References: <6398202.hrOAl1xuJE@wuerfel>
 <561CAD6D.2060105@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	huangdaode <huangdaode@hisilicon.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:42856 "EHLO smtpbg202.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932270AbbJMN1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 09:27:23 -0400
Content-Disposition: inline
In-Reply-To: <561CAD6D.2060105@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 03:06:21PM +0800, huangdaode wrote:
> Date: Tue, 13 Oct 2015 15:06:21 +0800
> From: huangdaode <huangdaode@hisilicon.com>
> To: Kenneth Lee <kenneth_lee_2012@126.com>
> Subject: Fwd: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once
>  HANDEL_TX_MSG macro
> Message-ID: <561CAD6D.2060105@hisilicon.com>
> 
>    -------- Forwarded Message --------
> 
>     Subject: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once      
>              HANDEL_TX_MSG macro                                              
>        Date: Mon, 12 Oct 2015 13:59:39 +0200                                  
>        From: Arnd Bergmann <arnd@arndb.de>                                    
>          To: huangdaode <huangdaode@hisilicon.com>                            
>          CC: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,    
>              Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,                 
>              linuxarm@huawei.com, salil.mehta@huawei.com,                     
>              kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,              
>              lisheng011@huawei.com, linux-kernel@vger.kernel.org              
> 
>  On Monday 12 October 2015 11:23:44 huangdaode wrote:
>  > +                       s += sprintf(s,
>  > +                                   "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n",
>  > +                                   h->qs[i]->tx_ring.io_base,
>  > +                                   h->qs[i]->tx_ring.buf_size,
>  > +                                   h->qs[i]->tx_ring.desc_num,
>  > +                                   h->qs[i]->tx_ring.max_desc_num_per_pkt,
>  > +                                   h->qs[i]->tx_ring.max_raw_data_sz_per_desc,
>  > +                                   h->qs[i]->tx_ring.max_pkt_size,
>  > +                                   h->qs[i]->tx_ring.stats.sw_err_cnt,
>  > +                                   h->qs[i]->tx_ring.stats.io_err_cnt);
> 
>  There is actually a more significant problem with this code, which I
>  failed to notice when doing the original bugfix:
> 
>  You have a sysfs interface here that exports internal data of the
>  device that should not be visible like this. One problem is that
>  the io_base is a kernel pointer that must not be visible to non-root
>  users (so we don't easily create an attack surface for exploits).
>  Another problem is that the format is not documented in Documentation/ABI/
>  and that you have multiple values in one sysfs file here.
> 
>  It would probably be better to completely remove that sysfs interface, and
>  to use the ethtool netlink interface to export them.
> 
>          Arnd
> 
>  .

Hi, Arnd,

Thank you for the comment. Yes, the io_base is a security problem, we
will fix it in coming patch soon.

But can we keep the sysfs? The interface from hnae is not used only by
ethernet driver but also by Open Data Plane driver. If we more it to
upper layers. Both drivers will have the same logic. 

So how about we just add documents to Documention/ABI?

Thanks
-- 
			-Kenneth Lee (Hisilicon)
