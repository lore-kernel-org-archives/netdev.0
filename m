From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth fixes for 2.6.27
Date: Tue, 9 Sep 2008 04:04:02 +0200
Message-ID: <0E7517ED-A2C3-4DFB-9733-0DAEA82F3815@holtmann.org>
References: <1220910837.11655.28.camel@californication> <20080908.170516.176909371.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54820 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbYIICEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 22:04:08 -0400
In-Reply-To: <20080908.170516.176909371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>> The second patch fixes the authentication requirements. We do have to
>> separate between service discovery and actual profile channels.  
>> This is
>> a clear requirement of the Bluetooth Security Mode 4 introduced  
>> with the
>> addition of the Simple Pairing support. Not fixing this will result  
>> in
>> broken behavior when doing service discovery with Simple Pairing  
>> enabled
>> devices.
>
> What regression reported by a user is fixed by this?
>
> This does not look like it is appropriate outside of the merge window.

the regression is that with Bluetooth 2.0 and before we always were  
allowing service discovery (SDP) connection without any bonding  
requirement. This is still true, but with Bluetooth 2.1 enabled  
devices it can now happen that we have to do a full pairing procedure.  
For SDP it should be at least using pairing with a just-works model  
with the no bonding requirement, while the other PSM channels (RFCOMM,  
BNEP etc.) should use generic bonding. We would now always use generic  
bonding (even for SDP).

The number of users are still limited to a few people actually testing  
with 2.1 hardware. These are mainly people working on 2.1 enabled  
products. However with the new MacBooks and the EeePC 901 we do have  
devices with Bluetooth 2.1 chips available for everybody.

This is clearly an oversight on my hand when developing the initial  
Simple Pairing patches that I submitted for 2.6.27-rc1 and I only  
found it when we tested against the official Bluetooth 2.1 test system.

This patch also fixes the issue when we for example wanna connect a  
BNEP connection with a 2.1 device. The requirement is that this has to  
be secure. However without this patch it pairs it during ACL  
connection setup and then again to ensure the man-in-the-middle  
protection. This decreases the connection setup time since the 2.1 key  
generation procedure takes 3-5 seconds and doing this twice is an  
significant penalty compared to 2.0 and before devices.

I think it is appropriate outside the merge window, but if you don't  
think so, I gonna pull that patch and only submit the other two.

Regards

Marcel

