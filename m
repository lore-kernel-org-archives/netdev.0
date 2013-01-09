From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [E1000-devel] [PATCH net-next] igbvf: fix setting addr_assign_type
 if PF is up
Date: Wed, 09 Jan 2013 18:58:30 +0100
Message-ID: <50EDAFC6.3070700@kpanic.de>
References: <1357725564-5581-1-git-send-email-sassmann@kpanic.de> <AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B527A@FMSMSX107.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout114.xlhost.de ([213.202.242.114]:48866 "EHLO
	app1a.xlhost.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932241Ab3AISIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 13:08:32 -0500
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B527A@FMSMSX107.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.01.2013 18:09, Williams, Mitch A wrote:
>> -----Original Message-----
>> From: Stefan Assmann [mailto:sassmann@kpanic.de]
>> Sent: Wednesday, January 09, 2013 1:59 AM
>> To: netdev@vger.kernel.org
>> Cc: e1000-devel@lists.sourceforge.net; sassmann@kpanic.de
>> Subject: [E1000-devel] [PATCH net-next] igbvf: fix setting
>> addr_assign_type if PF is up
>>
>> When the PF is up and igbvf is loaded the MAC address is not generated
>> using eth_hw_addr_random(). This results in addr_assign_type not to be
>> set.
>> Make sure it gets set.
>>
> 
> NAK - In this case, the address may or may not be random. The user may
> have (and should have!) explicitly set this address from the host to
> ensure that the VF device receives the same address each time it boots.

Maybe you can give me some advice on this then. Why is there different
behaviour depending on the PF being up or down? The problem I'm facing
is that if the user did not set a MAC address for the VF manually and
the PF is up during igbvf_probe it will not be labelled as random
although it is.
What about checking IGB_VF_FLAG_PF_SET_MAC and only set NET_ADDR_RANDOM
if the flag is cleared?

  Stefan
