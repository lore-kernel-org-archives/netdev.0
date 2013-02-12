From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
Date: Tue, 12 Feb 2013 13:03:35 +0100
Message-ID: <511A2F97.6090209@denx.de>
References: <1360660088-27464-1-git-send-email-sr@denx.de> <6A3DF150A5B70D4F9B66A25E3F7C888D065A0271@039-SN2MPN1-023.039d.mgd.msft.net> <511A219A.7080000@denx.de> <6A3DF150A5B70D4F9B66A25E3F7C888D065A1614@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	Anatolij Gustschin <agust@denx.de>,
	"David S. Miller" <davem@davemloft.net>
To: Bhushan Bharat-R65777 <R65777@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:41178 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758826Ab3BLMDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:03:55 -0500
In-Reply-To: <6A3DF150A5B70D4F9B66A25E3F7C888D065A1614@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.02.2013 12:23, Bhushan Bharat-R65777 wrote:
>>> Why we read from MAC registers if Linux should not rely on bootloader?
>>
>> It was suggested by David. Backwards compatibility. Here Davids comment to my
>> original patch which removed this register reading completely:
>>
>> "
>> I don't think this is a conservative enough change.
>>
>> You have to keep the MAC register reading code around, as a backup code path in
>> case the OF device node lacks a MAC address "
> 
> Ok,
> 
> But this is really a backward compatibility or hiding some bug? My
> thought is that if DT does not have a valid MAC address then it is
> a BUG and should be fixed. Is not it?

Yes. But it can only be fixed in the bootloader then. And some people
might not want to do this or might be unable to do this. So lets keep
this "feature" available for such cases.

BTW: U-Boot traditionally always wrote the MAC address into the FEC
registers. Even if FEC was not used in U-Boot at all. I only noticed
this problem with the new SPL fastbooting U-Boot version, which is
basically a very stripped down U-Boot version directly booting into
Linux (or U-Boot if selected). Here the FEC registers are not touched at
all. And the Linux FEC driver then woke up with an invalid MAC address.

Thanks,
Stefan
