From: "Randy.Dunlap" <randy.dunlap@oracle.com>
Subject: Re: [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Thu, 26 Oct 2006 08:51:09 -0700
Message-ID: <4540D96D.601@oracle.com>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <20061025201341.GH21200@miggy.org> <20061025151737.1bf4898c.randy.dunlap@oracle.com> <20061025222709.A13681C5E0B@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <20061025165858.b76b4fd8.randy.dunlap@oracle.com> <20061026154635.GK27968@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>, toralf.foerster@gmx.de,
	netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	link@miggy.org, greg@kroah.com, akpm@osdl.org,
	zippel@linux-m68k.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, dbrownell@users.sourceforge.net,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:9576 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1423464AbWJZPxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 11:53:36 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061026154635.GK27968@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Wed, Oct 25, 2006 at 04:58:58PM -0700, Randy Dunlap wrote:
>> ...
>> Build tested with CONFIG_MII=y, m, n.
>> ...
>> --- linux-2619-rc3-pv.orig/drivers/usb/net/usbnet.c
>> +++ linux-2619-rc3-pv/drivers/usb/net/usbnet.c
>> @@ -47,6 +47,12 @@
>>  
>>  #define DRIVER_VERSION		"22-Aug-2005"
>>  
>> +#if defined(CONFIG_MII) || defined(CONFIG_MII_MODULE)
>> +#define HAVE_MII		1
>> +#else
>> +#define HAVE_MII		0
>> +#endif
>> ...
> 
> I'm too lame to test it, but I bet this will break with
> CONFIG_USB_USBNET=y, CONFIG_MII=m, and you'll actually need
> 
>   #if defined(CONFIG_MII) || (defined(CONFIG_MII_MODULE) && defined(MODULE))
> 
> And then there's the question whether this amount of #ifdef's is 
> actually worth avoiding the "select MII"...

Thanks, but that's OK, David posted a different patch for it.

-- 
~Randy
