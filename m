From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: DSA and underlying 802.1Q encapsulation
Date: Thu, 28 May 2015 09:44:47 -0400 (EDT)
Message-ID: <1072166088.99991.1432820687442.JavaMail.zimbra@savoirfairelinux.com>
References: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com> <20150526225142.GB26454@roeck-us.net> <1250227394.1145458.1432759717091.JavaMail.zimbra@savoirfairelinux.com> <556630EA.7060707@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Chris Healy <cphealy@gmail.com>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64309 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbbE1Nou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 09:44:50 -0400
In-Reply-To: <556630EA.7060707@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

>>> If yes, the dsa code may need to move the tag into the header.
>>> If we are lucky, a call to vlan_hwaccel_push_inside() might do it.
>>
>> Thanks, I'm currently looking into it and doing some tests, I'm coming back to
>> you asap.

Issue fixed, thanks! vlan_hwaccel_push_inside() adds additional memmove, but
this approach is simpler.

>>> Do you have some vlan dsa code to share, by any chance ? That might
>>> save me some time, as I am looking into it as well.
>>
>> Yes, I am about the send an RFC for fully integrated 802.1q VLAN support on
>> Marvell 88E6352 devices.
>>
> Excellent, that is going to safe me a lot of work! If you don't mind,
> please Cc: me as I am not subscribed to the network mailing list.

My work is based on v4.1-rc3. Unfortunately the VLAN support breaks on latest
net-next/master (e.g. NETIF_F_HW_SWITCH_OFFLOAD is removed; .ndo_bridge_setlink
used to set tag and PVID, is moved to switchdev.)

Are you willing to give it a try based on v4.1-rc3 in the meantime?
Otherwise, I'll send the RFC as soon as the support is functional on net-next.

Thanks,
-v
