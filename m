From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Mon, 4 Jun 2012 23:15:48 +0300
Message-ID: <CAEnQRZDH6te-xa1E5aohs7+MWfAwsx-eOCP1tQ9vZRDmEO=C+Q@mail.gmail.com>
References: <4FCCFE76.3060304@candelatech.com>
	<CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
	<4FCD15E7.4080700@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:40143 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2FDUPs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 16:15:48 -0400
Received: by vcbf11 with SMTP id f11so2712500vcb.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 13:15:48 -0700 (PDT)
In-Reply-To: <4FCD15E7.4080700@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 4, 2012 at 11:09 PM, Ben Greear <greearb@candelatech.com> w=
rote:
> On 06/04/2012 12:22 PM, Daniel Baluta wrote:
>>
>> On Mon, Jun 4, 2012 at 9:29 PM, Ben Greear<greearb@candelatech.com>
>> =A0wrote:
>>>
>>> I'm going some TCP performance testing on wifi -> =A0LAN interface
>>> connections.
>>> =A0With
>>> UDP, we can get around 250Mbps of payload throughput. =A0With TCP, =
max is
>>> about 80Mbps.
>>>
>>> I think the problem is that there are way too many ACK packets, and
>>> bi-directional
>>> traffic on wifi interfaces really slows things down. =A0(About 7000=
 pkts
>>> per
>>> second in
>>> upload direction, 2000 pps download. =A0And the vast majority of th=
e
>>> download
>>> pkts
>>> are 66 byte ACK pkts from what I can tell.)
>>>
>>> Kernel is 3.3.7+
>>>
>>> Anyone know of any tuning parameters that would let the receiving s=
ocket
>>> wait a
>>> bit longer and send more ACK data in fewer packets?
>>
>>
>> An ACK is generated after every second full sized segment or a timeo=
ut
>> expires.
>>
>> Currently, there is no way to tune these parameters. Here is an
>> experimental
>> patch [1]. If anyone, thinks that this patch has a chance to get acc=
epted
>> I will be happily try to further improve it.
>
>
> It looks like it could be useful for my case, but I would also want
> per-socket options to set the min/max ack delay so that the settings
> are not just system-wide.
>
> I can at least test this, and perhaps even hack on the code if
> you are not interested in the per-socket settings...

Yes, indeed this should be a per socket option. I will be
back with a patch in the next days.

Meanwhile, it would be great if you could test my previous patch.

thanks,
Daniel.
