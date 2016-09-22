From: Mark Tomlinson <Mark.Tomlinson@alliedtelesis.co.nz>
Subject: Re: [PATCH] net: VRF: Fix receiving multicast traffic
Date: Thu, 22 Sep 2016 22:10:36 +0000
Message-ID: <ee8de997-007c-4035-5f65-a8b389a138ac@alliedtelesis.co.nz>
References: <20160922041308.30848-1-mark.tomlinson@alliedtelesis.co.nz>
 <aac5b560-d757-3281-8e69-7953e7c4b418@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
To: David Ahern <dsa@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:48849 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933738AbcIVWKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 18:10:40 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 18D5386053
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:10:38 +1200 (NZST)
In-Reply-To: <aac5b560-d757-3281-8e69-7953e7c4b418@cumulusnetworks.com>
Content-Language: en-US
Content-ID: <B32AA5B016A73241B7439B0A3F6D9FD3@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/23/2016 03:14 AM, David Ahern wrote:
>
> l3mdev devices do not support IPv4 multicast so checking mcast against th=
at device should not be working at all. For that reason I was fine with the=
 change in the previous patch. ie., you want the real ingress device there =
not the vrf device.
>
> What test are you running that says your previous patch broke something?
Although we do not expect any multicast routing to work in an l3mdev,=20
(IGMP snooping or PIM), we still want to have multicast packets=20
delivered for protocols such as RIP. This was working before my previous=20
patch, but these multicast packets are now dropped. This current patch=20
fixes that again, hopefully still with the benefits of my first patch.
