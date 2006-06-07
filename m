From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 12:07:27 -0500
Message-ID: <448707CF.7080506@lwfinger.net>
References: <4485D66B.7080108@lwfinger.net> <1149682213.3999.14.camel@johannes> <4486F513.5050906@lwfinger.net> <1149695470.3925.7.camel@johannes> <4486F866.9040901@errno.com> <1149696400.3925.13.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sam Leffler <sam@errno.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:52866 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932344AbWFGRHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 13:07:32 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1149696400.3925.13.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2006-06-07 at 09:01 -0700, Sam Leffler wrote:
> 
>> Beware of the order of IE's in the management frames; some AP's are
>> touchy about this.
> 
> Uh oh. I have no idea where the ieee80211 layer sticks that one,
> probably at the end.

I moved the WPA IE from the end forward without any effect. I have dumped that IE and find the 
following:

SoftMAC: Added WPA_IE of 24 bytes to association request
Contents of WPA_IE: 0xdd 0x16 0x00 0x50 0xf2 0x01 0x01 0x00 0x00 0x50
                     0xf2 0x02 0x01 0x00 0x00 0x50 0xf2 0x02 0x01 0x00
                     0x00 0x50 0xf2 0x02

I think I got the right thing, but I'm having trouble interpreting it. The dump was made by 
modifying the part of ieee80211softmac_assoc_req in ieee80211softmac_io.c where the WPA IE is added:

         /* Add WPA IE */
         if (mac->wpa.IElen && mac->wpa.IE) {
                 int i;
                 memcpy(data, mac->wpa.IE, mac->wpa.IElen);
                 data += mac->wpa.IElen;
                 printk(KERN_INFO PFX "Added WPA_IE of %d bytes to association request\n"
                         "Contents of WPA_IE: ", mac->wpa.IElen);
                 for (i=0; i<mac->wpa.IElen; i++)
                         printk("0x%02x ",mac->wpa.IE[i]);
                 printk("\n");
         }

Larry
