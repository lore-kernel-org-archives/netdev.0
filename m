From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sat, 17 Jun 2017 14:11:11 +0200
Message-ID: <20170617121111.GA1974@lunn.ch>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-3-salil.mehta@huawei.com>
 <20170614013750.GG23384@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2C54@FRAEML521-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2C54@FRAEML521-MBS.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > +subsys_initcall(hnae3_init);
> > 
> > And the point of this is?
> > 
> >     Andrew
> This looks weird but not sure how we could have made sure HNAE is available before other
> 2 drivers could have loaded. Changing into module_init() means two other modules (dependent
> upon hnae) if loaded first will experience load time linking problems. Do you think this
> is okay? 

Often the best way to decide if something is sensible is to see if
lots of other drivers do the same. Can you point to other drivers
doing this?

depmod/modprobe will actually sort this out for you. depmod looks at
the symbols exported and required for each module and builds a
dependency tree. When you modprobe a driver, it looks at the
dependency tree, and loads any drivers needed in order to fulfil the
dependencies.

	Andrew
