From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v2 5/9] mlx4: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Tue, 3 May 2016 08:29:18 -0700
Message-ID: <CAKgT0UeK2ss9AsxdvyDHArXXVZMZG7AL6f0iXQukSg135B64cQ@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
	<20160429224333.12418.13862.stgit@ahduyck-xeon-server>
	<CAJ3xEMiog9zEwg_S=jG5LjM6FpvtyffvPcYX_G4j-ubBE_wLDw@mail.gmail.com>
	<CAKgT0UdV2ruuRsYLmOjnqbXW0_i4QqMfo+VhuCSBqJjWrKhRdQ@mail.gmail.com>
	<CAJ3xEMj_Vez_pP0ZTVATR=AMNDF1fneZ3dVrfWT7NP1mj4APRQ@mail.gmail.com>
	<CAKgT0UdeuJA-K8zim5Eact9A2oFscXDC2a7ciKGTo74xptuw4w@mail.gmail.com>
	<57289C95.8030401@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <michael.chan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33607 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270AbcECP3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 11:29:24 -0400
Received: by mail-io0-f171.google.com with SMTP id f89so25958035ioi.0
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 08:29:18 -0700 (PDT)
In-Reply-To: <57289C95.8030401@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 3, 2016 at 5:41 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> On 5/2/2016 6:41 PM, Alexander Duyck wrote:
>>>
>>> >Just one more piece to clarify... in the general case (e.g inner
>>> >packet size 1.5k...64k), the last segment would not have the same
>>> >length as the other segments, what happens on that case?
>>
>> Actually in the case of GSO partial we have go through the software
>> segmentation code and trim off any last bit that doesn't match the MSS
>> of the rest of the frame.  That way you end up with one frame that has
>> some number of MSS sized chunks, and then one remainder if there is a
>> frame that would be a different size.
>
>
> OK, thanks for further clarifying this, will look on the docs you pointed
> etc. From what you wrote here I understand it's indeed possible for one
> frame to be of different size from the rest, but the LCO thing still works
> somehow..

We split the one that would be a different size off via GSO.  So we
end up sending up 2 frames to the device if there is going to be one
piece that doesn't quite match.  We split that one piece off via GSO.
That is one of the reasons why I referred to it as partial GSO as all
we are using the software segmentation code for is to make sure we
have the GSO block consists of segments that are all the same size.

- Alex
