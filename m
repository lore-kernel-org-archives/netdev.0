From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: ieee80211 patches
Date: Fri, 26 Aug 2005 11:07:07 -0400
Message-ID: <200508261107.07501.flamingice@sourmilk.net>
References: <20050825193112.529d0dc9@griffin.suse.cz> <200508252049.52413.flamingice@sourmilk.net> <20050826140831.5ec0f301@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, NetDev <netdev@vger.kernel.org>,
        Jeff Garzik <jgarzik@pobox.com>, jbohac@suse.cz, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20050826140831.5ec0f301@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 26 August 2005 08:08, Jiri Benc wrote:
> On Thu, 25 Aug 2005 20:49:52 -0400, Michael Wu wrote:
> > I hope to submit the adm8211 driver for review soon, but there's a bunch
> > of code in the driver which probably belong in the ieee80211 code:
> >
> > - Duplicate frame removal
> > - Definitions for all management payloads
> > - SIOCSIWENCODEEXT and SIOCGIWENCODEEXT
> > - AVS capture header in monitor mode
> > - Software Scanning
> > - Software Authentication & Association
> >
> > Does that sound okay? I will start submitting patches to add those things
> > if they should be in the ieee80211 code.
>
> Sounds great. Could you post a pointer to the project?
>
http://aluminum.sourmilk.net/adm8211/index.php?path=netdev/

> Btw, Andrea Merello has a code for some of these features in his
> rtl8180-sa2400 project (http://sourceforge.net/projects/rtl8180-sa2400)
> too - we are trying to subsequently include them.
>
Hmm..

- adm8211 supports shared key authentication, rtl8180-sa2400 only supports 
open authentication. (which is kinda okay when you consider that 802.11i 
doesn't use shared key)
- Both drivers do not support LEAP authentication.
- adm8211 supports WE18/WPA (partly via SIWGENIE, it doesn't generate WPA/RSN 
IEs itself)
- rtl8180-sa2400 supports a really simple master mode. (should something like 
hostapd be used instead for master mode?)
- rtl8180-sa2400 supports sending probe responses. adm8211 lets the hardware 
do it, though newer adm8211 cards can be told to hand it off to the software.
- rtl8180-sa2400 creates a completely random bssid in adhoc. adm8211 keeps the 
first 3 octets from the MAC addr.
- adm8211 supports sending & handling deauthentication and disassociation 
frames. I did not see definitions for those frames, so I assume there's no 
support there.
- adm8211 needs many hooks in scanning/authentication/association to set 
BSSID/SSID/AID/etc. in hardware.
- rtl8180-sa2400 doesn't seem to convert to little endian in a number of 
places. (not really major..)

-Michael Wu
