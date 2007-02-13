From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Tue, 13 Feb 2007 14:55:45 -0800
Message-ID: <45D241F1.8040606@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com> <200702131558.48987.ismail@pardus.org.tr> <b6a2187b0702130710s217281c4k5ed227995c09c878@mail.gmail.com> <200702131857.02369.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Chua <jeff.chua.linux@gmail.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:37744 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751459AbXBMXiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 18:38:10 -0500
In-Reply-To: <200702131857.02369.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ismail D=F6nmez wrote:
> On Tuesday 13 February 2007 17:10:24 Jeff Chua wrote:
>> On 2/13/07, Ismail D=F6nmez <ismail@pardus.org.tr> wrote:
>>> Tried this is on a patched 2.6.20 kernel with ipw3945 device and it
>>> always puts the card in 802.11a mode instead of 802.11bg mode.
>>>
>>> Ideas?
>> Before running  "iwconfig wlan0 channel 8",  the card is set to
>> 802.11a mode. iwconfig shows rate at 54Mb/s. But after setting the
>> channel, it sets to 802.11b mode, and I can't find a way to change
>> from 11Mb/s to 54MB/s.
>>
>> "iwlist eth0 rate" only show up to 11Mb/s.
>>
>> So, my problem is the card is always in 802.11b mode.
>=20
> So I guess there is a common problem with a/bg modes?

Regardless of what iwconfig reports as the mode or rate, you should be=20
able to associate to an AP in either spectrum (2.4 or 5.2) using any=20
valid rate.  Once configured and associated, iwconfig should provide=20
more correct information.

If association is failing, verify that 'iwlist scan' shows the AP and=20
that you specify everything for the association, eg:

    iwconfig wlan0 channel 8 essid MyAP ap 00:13:f0:0d:ca:fe

d80211 will only attempt to associate once -- if it fails, then you nee=
d=20
to currently "de-configure" the device and reconfigure it back to what=20
you want to associate to.  I do that here by chaging the AP BSSID to=20
something else then changing it back.  If you use wpa_supplicant, it=20
does the re-association attempts for you.

James
