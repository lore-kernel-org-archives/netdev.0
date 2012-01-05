From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 05 Jan 2012 12:20:04 -0500 (EST)
Message-ID: <20120105.122004.1170447281304011158.davem@davemloft.net>
References: <1325770673-17309-1-git-send-email-festevam@gmail.com>
	<4F05CBA9.1070602@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F05CBA9.1070602-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date: Thu, 05 Jan 2012 10:11:21 -0600

> On 01/05/2012 07:37 AM, Fabio Estevam wrote:
>> Fix the following build warning:
>>
>> warning: (KS8851&& AX88796_93CX6&& RTL8180&& RTL8187&& ADM8211&&
>> RT2400PCI&& RT2500PCI&& RT61PCI&& RT2800PCI&& R8187SE) selects
>> EEPROM_93CX6 which has unmet direct dependencies (MISC_DEVICES)
>>
>> Signed-off-by: Fabio Estevam<fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>> ---
>> Changes since v1:
>> - Place MISC_DEVICES dependency into the 'depends on' line
> 
> Is this the right way to fix this? Whenever I get this kind of build
> warning, I usually attribute it to a problem with my local
> configuration and fix my copy of .config, not modify the build
> system. With this change, it seems to me that a lot of devices will
> suddenly disappear from the build with little explanation. I don't
> feel confident enough to NACK the patch, but I would like an expert to
> comment.
> 
> I have noticed that the defconfigs for various architectures are split
> between turning MISC_DEVICES on or off.

Right, this is definitely the wrong fix, "select" is the right way to
fix this because no user should have to know the gory details of what
random odd config variables have to be on already in order to turn on
support for a device they are interested in.

Fix this right, by using "select MISC_DEVICES"
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
