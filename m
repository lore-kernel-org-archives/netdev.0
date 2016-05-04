From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [net-next PATCH v2 5/9] mlx4: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Wed, 4 May 2016 18:50:33 +0300
Message-ID: <572A1A49.9020507@mellanox.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
 <20160429224333.12418.13862.stgit@ahduyck-xeon-server>
 <CAJ3xEMiog9zEwg_S=jG5LjM6FpvtyffvPcYX_G4j-ubBE_wLDw@mail.gmail.com>
 <CAKgT0UdV2ruuRsYLmOjnqbXW0_i4QqMfo+VhuCSBqJjWrKhRdQ@mail.gmail.com>
 <CAJ3xEMj_Vez_pP0ZTVATR=AMNDF1fneZ3dVrfWT7NP1mj4APRQ@mail.gmail.com>
 <CAKgT0UdeuJA-K8zim5Eact9A2oFscXDC2a7ciKGTo74xptuw4w@mail.gmail.com>
 <57289C95.8030401@mellanox.com>
 <CAKgT0UeK2ss9AsxdvyDHArXXVZMZG7AL6f0iXQukSg135B64cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <michael.chan@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	"Eran Ben Elisha" <eranbe@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0087.outbound.protection.outlook.com ([157.56.112.87]:16741
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751125AbcEDPuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 11:50:44 -0400
In-Reply-To: <CAKgT0UeK2ss9AsxdvyDHArXXVZMZG7AL6f0iXQukSg135B64cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/2016 6:29 PM, Alexander Duyck wrote:
> We split the one that would be a different size off via GSO.  So we
> end up sending up 2 frames to the device if there is going to be one
> piece that doesn't quite match.  We split that one piece off via GSO.
> That is one of the reasons why I referred to it as partial GSO as all
> we are using the software segmentation code for is to make sure we
> have the GSO block consists of segments that are all the same size.

I see, so if somehow it happens a lot that the TCP stack sends down 
something which once segmented ends up with the last segment being of 
different size from the other ones we would have to call the NIC xmit 
function twice (BTW can we use xmit_more here?)  -- which could be 
effecting performance, I guess.

GSO_UDP_TUNNEL_CSUM (commit  0f4f4ffa7 "net: Add GSO support for UDP 
tunnels with checksum") came to mark "that a device is capable of 
computing the UDP checksum in the encapsulating header of a UDP tunnel" 
-- and the way we use it here is that we do advertize that bit towards 
the stack for devices whose HW can **not** do that, and things work b/c 
of LCO (this is my understanding).

I miss something in the bigger picture here, what does this buy us? e.g 
vs just letting this (say) vxlan tunnel use zero checksum on the outer 
UDP packet, is that has something to do with RCO?

Or.
