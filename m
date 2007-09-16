From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sun, 16 Sep 2007 03:50:25 -0400
Message-ID: <46ECE041.3090001@garzik.org>
References: <20070915132220.GE6060@tuxdriver.com> <200709152017.02646.flamingice@sourmilk.net> <46EC7F33.2050206@garzik.org> <200709160047.45128.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200709160047.45128.flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> On Saturday 15 September 2007 20:56, Jeff Garzik wrote:
>>>>> +	if (flags & IFF_PROMISC)
>>>>> +		dev->flags |= IEEE80211_HW_RX_INCLUDES_FCS;
>>>>> +	else
>>>>> +		dev->flags &= ~IEEE80211_HW_RX_INCLUDES_FCS;
>>>> why does promisc dictate inclusion of FCS?
>>> Because that's the way the hardware works.
>> Why not always include it, regardless of promisc?
>>
> I really do mean that's how the hardware works. If you turn on the promisc bit 
> in the hardware (which IFF_PROMISC causes), it starts including the FCS, but 
> if the bit is not set, the FCS is not included in frames.

OK, I was confused by the name.  Based on the constant's name, I was 
assuming that you could unconditionally enable it, promisc or not. 
Nevermind.  I thought that was a hardware rather than software bit.


> What form of debugging are you talking about? I don't see how it makes a 
> difference for debugging. The type checking provided by enums won't make a 

When you are tracing through with kgdb, the code is actually readable. 
You see

	dev->flags |= IEEE80211_HW_RX_INCLUDES_FCS;

rather than the far more obtuse

	dev->flags |= 8;

Ditto for any time you have to read pre-processed source code.  I do so 
at least once a month, since post-cpp code shows you precisely what the 
compiler is munching, after all the macro magic goes away.

	Jeff
