From: "ericj" <ericj@ericj.net>
Subject: Re: e100 (was: eepro100) - Nobody Cares (hardware?)
Date: Tue, 7 Aug 2007 07:49:15 -0500
Message-ID: <20070807124323.M90873@ericj.net>
References: <20070806152244.M31050@ericj.net> <46B748A8.4030608@garzik.org> <20070806161747.M31655@ericj.net> <20070806205908.M61217@ericj.net> <46B7C095.5010202@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=OPENWEBMAIL_ATT_0.277153554462956"
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host22.the-web-host.com ([209.239.41.243]:40866 "EHLO
	host22.the-web-host.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759303AbXHGNLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 09:11:35 -0400
In-Reply-To: <46B7C095.5010202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=OPENWEBMAIL_ATT_0.277153554462956
Content-Type: text/plain;
	charset=iso-8859-1

On Mon, 06 Aug 2007 17:45:09 -0700, Kok, Auke wrote
> [moving to netdev mailinglist]
> Eric,
> 
> please don't forget that an entire team here at Intel is 
> dedicated to supporting e100 and pro/1000 devices from Intel.
> 
> Most of the pro/100 features are documented in the SDM which 
> contains some references to the eeprom parts. Mostly the 
> device doesn't need much configuration from the eeprom to work 
> (unlike gigE parts). The SDM can be downloaded from our sf.net 
> project page:
> 
>
http://sourceforge.net/project/showfiles.php?group_id=42302&package_id=68544
> 
> The issue that you are reporting:
> 
> "My system boots fine but when I try to bring up the onboard 
> ethernet (an EEPro 100 VE) I get a "Nobody Cares" message and 
> the interrupt is disabled."
> 
> However has been recently patched. This should have worked 
> regardless of whether you used e100 or eepro100 (noting that 
> nobody supports eepro100 anymore, you should really use e100 
> for all tests).
> 
> if you look in drivers/pci/quirks.c you'll find that there is 
> specific code for e100 devices. If this quirk doesn't work for 
> you then we'll need to dig into that. For this I'd like you to 
> gather:
> 
> - `ethtool -e eth0` output
> - `lspci -n` output
> 
> this will allow me to check the quirck code and see if it has 
> the right device ID. I'm suspecting that the device ID is 
> missing somehow, or the workaround fails.
> 
> Auke

Thanks for the help.

Here are the lspci -n and ethtool -e outputs. I am attaching both the
results for the 'bad' unit and for another one which is supposedly
identical except for some battery charge circuitry.

The eeprom data on the bad one may be a little odd due to my trying to
make it match that of the good one, including that I forgot what the
real MAC address was supposed to be.

I can get one that I haven't screwed up if you need it, but it will
probably take all day.

--

"A hunch is creativity trying to tell you something" -- Frank Capra

Eric Johnson


------=OPENWEBMAIL_ATT_0.277153554462956
Content-Type: application/octet-stream;
	name="lspci_good.txt"
Content-Disposition: attachment; filename="lspci_good.txt"
Content-Transfer-Encoding: base64

MDA6MDAuMCAwNjAwOiA4MDg2OjM1ODAgKHJldiAwMikKMDA6MDAuMSAwODgwOiA4MDg2OjM1ODQg
KHJldiAwMikKMDA6MDAuMyAwODgwOiA4MDg2OjM1ODUgKHJldiAwMikKMDA6MDIuMCAwMzAwOiA4
MDg2OjM1ODIgKHJldiAwMikKMDA6MDIuMSAwMzgwOiA4MDg2OjM1ODIgKHJldiAwMikKMDA6MWQu
MCAwYzAzOiA4MDg2OjI0YzIgKHJldiAwMikKMDA6MWQuMSAwYzAzOiA4MDg2OjI0YzQgKHJldiAw
MikKMDA6MWQuMiAwYzAzOiA4MDg2OjI0YzcgKHJldiAwMikKMDA6MWQuNyAwYzAzOiA4MDg2OjI0
Y2QgKHJldiAwMikKMDA6MWUuMCAwNjA0OiA4MDg2OjI0NGUgKHJldiA4MikKMDA6MWYuMCAwNjAx
OiA4MDg2OjI0YzAgKHJldiAwMikKMDA6MWYuMSAwMTAxOiA4MDg2OjI0Y2IgKHJldiAwMikKMDA6
MWYuMyAwYzA1OiA4MDg2OjI0YzMgKHJldiAwMikKMDA6MWYuNSAwNDAxOiA4MDg2OjI0YzUgKHJl
diAwMikKMDE6MDguMCAwMjAwOiA4MDg2OjEwM2EgKHJldiA4MikKMDE6MGMuMCAwMjgwOiAxODE0
OjAzMDIKMDE6MGQuMCAwNjA3OiAxMDRjOmFjNTUgKHJldiAwMSkKMDE6MGQuMSAwNjA3OiAxMDRj
OmFjNTUgKHJldiAwMSkK

------=OPENWEBMAIL_ATT_0.277153554462956
Content-Type: application/octet-stream;
	name="lspci_bad.txt"
Content-Disposition: attachment; filename="lspci_bad.txt"
Content-Transfer-Encoding: base64

MDA6MDAuMCAwNjAwOiA4MDg2OjM1ODAgKHJldiAwMikKMDA6MDAuMSAwODgwOiA4MDg2OjM1ODQg
KHJldiAwMikKMDA6MDAuMyAwODgwOiA4MDg2OjM1ODUgKHJldiAwMikKMDA6MDIuMCAwMzAwOiA4
MDg2OjM1ODIgKHJldiAwMikKMDA6MDIuMSAwMzgwOiA4MDg2OjM1ODIgKHJldiAwMikKMDA6MWQu
MCAwYzAzOiA4MDg2OjI0YzIgKHJldiAwMikKMDA6MWQuMSAwYzAzOiA4MDg2OjI0YzQgKHJldiAw
MikKMDA6MWQuMiAwYzAzOiA4MDg2OjI0YzcgKHJldiAwMikKMDA6MWQuNyAwYzAzOiA4MDg2OjI0
Y2QgKHJldiAwMikKMDA6MWUuMCAwNjA0OiA4MDg2OjI0NGUgKHJldiA4MikKMDA6MWYuMCAwNjAx
OiA4MDg2OjI0YzAgKHJldiAwMikKMDA6MWYuMSAwMTAxOiA4MDg2OjI0Y2IgKHJldiAwMikKMDA6
MWYuMyAwYzA1OiA4MDg2OjI0YzMgKHJldiAwMikKMDA6MWYuNSAwNDAxOiA4MDg2OjI0YzUgKHJl
diAwMikKMDE6MDguMCAwMjAwOiA4MDg2OjEwM2EgKHJldiA4MikKMDE6MGMuMCAwMjgwOiAxODE0
OjAzMDIKMDE6MGQuMCAwNjA3OiAxMDRjOmFjNTUgKHJldiAwMSkKMDE6MGQuMSAwNjA3OiAxMDRj
OmFjNTUgKHJldiAwMSkK

------=OPENWEBMAIL_ATT_0.277153554462956
Content-Type: application/octet-stream;
	name="ethtool_bad.txt"
Content-Disposition: attachment; filename="ethtool_bad.txt"
Content-Transfer-Encoding: base64

T2Zmc2V0CQlWYWx1ZXMKLS0tLS0tCQktLS0tLS0KMHgwMDAwCQkwMCAwMiBiMyBjMCBmZiBlZSAw
MCAwMCAwMCAwMCBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDEwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDIwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDMwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDQwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDUwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDYwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDcwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiA0MiAwOSAK

------=OPENWEBMAIL_ATT_0.277153554462956
Content-Type: application/octet-stream;
	name="ethtool_good.txt"
Content-Disposition: attachment; filename="ethtool_good.txt"
Content-Transfer-Encoding: base64

T2Zmc2V0CQlWYWx1ZXMKLS0tLS0tCQktLS0tLS0KMHgwMDAwCQkwMCAxYiBlYyAwMCAwMCA1NyAw
MCAwMCAwMCAwMCBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDEwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDIwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDMwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDQwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDUwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDYwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAKMHgwMDcwCQlmZiBmZiBmZiBmZiBmZiBmZiBm
ZiBmZiBmZiBmZiBmZiBmZiBmZiBmZiAwOCA0OCAK

------=OPENWEBMAIL_ATT_0.277153554462956--
