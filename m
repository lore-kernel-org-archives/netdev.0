From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 14:42:06 -0800
Message-ID: <CALx6S34pkU6XYk4N8MRszae-GoZRzK4vct=WpcX_KC-O9J8p0w@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<20151208.120654.2127200076257822677.davem@davemloft.net>
	<56681B18.3030200@solarflare.com>
	<CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
	<566864C0.6020204@solarflare.com>
	<CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
	<20151209222153.GE11201@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:38392 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbbLIWmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:42:07 -0500
Received: by igbxm8 with SMTP id xm8so760032igb.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:42:06 -0800 (PST)
In-Reply-To: <20151209222153.GE11201@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 2:21 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/09/15 at 10:00am, Tom Herbert wrote:
>> On Wed, Dec 9, 2015 at 9:28 AM, Edward Cree <ecree@solarflare.com> wrote:
>> > Which only pushes the problem onto when someone wants to nest
>> > encapsulations.  (I heard you like tunnels, so I put a tunnel in your
>> > tunnel so you can encapsulate while you encapsulate.)
>> > Or to put it another way, 2 isn't a number; the only numbers are 0, 1
>> > and infinity ;)
>> > Perhaps in practice 2 csums would be enough, for now.  But isn't the
>> > whole point of the brave new world of generic checksums that it should
>> > be future-proof?
>> >
>> If there is a need then we can add an arbitrary number. But no one has
>> proven there is a need, however we do have a real need for checksum
>> offload outside of the narrow uses of  NETIF_F_IP[V6]_CSUM.
>
> Need may be a strong word here but people have started doing nested
> tunneling by running container orchestration tools which use VXLAN
> to isolate containers inside of OpenStack virtual infrastructure which
> also creates virtual networks.
>
> I'm not saying it's sane or desirable but we will start seeing nested
> tunnels in the wild :-(

csum_start and csum_offset together occupy 32 bits. As demonstrated in
VXLAN RCO we can compress csum_start/csum_offset down to 8 bits which
means if necessary we could get up to four pairs in an sk_buff without
increasing its size. If you need more that four checksums to be
offloaded in single packet then I doubt getting checksum offload to
work is going to be your biggest problem.
