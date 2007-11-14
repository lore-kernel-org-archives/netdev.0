From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous
 mode
Date: Wed, 14 Nov 2007 10:42:04 +0100
Message-ID: <473AC2EC.4060109@trash.net>
References: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au> <20071113.033611.73195922.davem@davemloft.net> <20071113120328.GB1086@gondor.apana.org.au> <20071113.040624.43544149.davem@davemloft.net> <20071113121647.GA1330@gondor.apana.org.au> <4739961E.90708@trash.net> <4739D3A5.4020503@intel.com> <4739DE29.2030507@trash.net> <4739DF29.6010901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, joonwpark81@gmail.com,
	w@1wt.eu, cfriesen@nortel.com, netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39294 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbXKNJmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:42:21 -0500
In-Reply-To: <4739DF29.6010901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Patrick McHardy wrote:
>> Kok, Auke wrote:
>>> Patrick McHardy wrote:
>>>
>>>> I already posted a patch for this, not sure what happened to it.
>>>> Auke, any news on merging the secondary unicast address support?
>>> I dropped the ball on that one. Care to resend it and send me one for
>>> e1000e as well?
>> Patch for e1000 attached.
>>
>> Does e1000e also work with PCI cards if I add the proper IDs?
>> Otherwise I could only send an untested patch.
>>
> 
> no, e1000e will only work with pci-e adapters. The code however is largely the
> same, so if you can dish me out (off-list) some test cases I can have our labs do
> the testing and add this to our test repertoire.


Actually that part of the code is quite different. I'm not
sure I understand the entire intent behind the differences,
why does it use a packed array of addresses instead of simply
passing the netdev pointer to the callback? That would be
necessary for secondary unicast support since we have to
disable unicast filtering if either the address count exceeds
the number of filter slots or the device is in promiscous mode.

