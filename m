From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Tue, 25 Jul 2017 09:35:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD003FB65@AcuExch.aculab.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-8-salil.mehta@huawei.com>
 <23ddbe00-8bef-a09b-5783-3a5438086bd6@gmail.com>
 <D7C5EFE3-632C-468D-B8E0-82B448634B31@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Salil Mehta <salil.mehta@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
        "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>
To: "'Rustad, Mark D'" <mark.d.rustad@intel.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:58526 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbdGYJgA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 05:36:00 -0400
In-Reply-To: <D7C5EFE3-632C-468D-B8E0-82B448634B31@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rustad, Mark D
> Sent: 24 July 2017 21:32
> > On Jul 23, 2017, at 10:05 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> >> +
> >> +	strncpy(drvinfo->version, HNAE_DRIVER_VERSION,
> >> +		sizeof(drvinfo->version));
> >> +	drvinfo->version[sizeof(drvinfo->version) - 1] = '\0';
> >
> > strlcpy() would probably do that for you.
> 
> You need to be careful about strlcpy - it does not completely write the destination buffer as strncpy
> does, and so can result in a kernel memory leak if the destination is not known to already be cleared.

Not only that, strlcpy() is defined to return the size of the
source string.
So if the source buffers isn't '\0' terminated it can fault.
(Not a problem above.)

Neither function is the one you were looking for.

	David
