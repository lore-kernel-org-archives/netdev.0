From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Fwd: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once HANDEL_TX_MSG macro
Date: Tue, 13 Oct 2015 16:18:23 +0200
Message-ID: <6914069.XLdT9Eli48@wuerfel>
References: <6398202.hrOAl1xuJE@wuerfel> <561CAD6D.2060105@hisilicon.com> <20151013132712.GA3310@kllt-03>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	huangdaode <huangdaode@hisilicon.com>
To: Kenneth Lee <Kenneth-Lee-2012@foxmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151013132712.GA3310@kllt-03>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 October 2015 21:27:12 Kenneth Lee wrote:
> 
> Hi, Arnd,
> 
> Thank you for the comment. Yes, the io_base is a security problem, we
> will fix it in coming patch soon.
> 
> But can we keep the sysfs? The interface from hnae is not used only by
> ethernet driver but also by Open Data Plane driver. If we more it to
> upper layers. Both drivers will have the same logic. 
> 
> So how about we just add documents to Documention/ABI?

Hi Kenneth,

In the end this is up to David Miller of course, but I'd say we are
better off not introducing any ABIs for ODP prematurely.

We are talking about very generic statistics data, and you should
already provide them for the ethernet driver using the standard
interfaces.

I have not seen any discussion about adding an ODP subsystem for
the Linux kernel, or what the API will be, but I think we should
not export any interfaces from a particular device driver directly
but always go through a common layer here and use an extensible
interface that can be implemented by everyone.

The API has not been part of a release yet, so I'd say we should
remove it for now. Once we have a net/odp/ directory, we can
add a driver-independent implementation there and call it from
the hisi driver.

	Arnd
