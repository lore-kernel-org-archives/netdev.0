From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net 0/5] Implement ndo_gso_check() for vxlan nics
Date: Wed, 5 Nov 2014 18:44:04 -0800
Message-ID: <CA+mtBx-Js62X3BpfjQkcsh=w=-cgvSyM5ueCpufGVv0uu1nphw@mail.gmail.com>
References: <CAJ3xEMhxabp1EKbFPfvoZEFt=CQKFNcNrURGMX=7miDwmK9Y-A@mail.gmail.com>
	<20141105.163825.1433973842938441546.davem@davemloft.net>
	<20141106010501.GA18339@gmail.com>
	<20141105.211558.969082848816106943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"linux.nics" <linux.nics@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	"shahed.shaikh" <shahed.shaikh@qlogic.com>,
	dept-gelinuxnicdev <Dept-GELinuxNICDev@qlogic.com>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:56158 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaKFCoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 21:44:06 -0500
Received: by mail-ig0-f170.google.com with SMTP id h15so9479915igd.1
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 18:44:05 -0800 (PST)
In-Reply-To: <20141105.211558.969082848816106943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014 at 6:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Joe Stringer <joestringer@nicira.com>
> Date: Wed, 5 Nov 2014 17:06:46 -0800
>
>> My impression was that the changes are more likely to be
>> hardware-specific (like the i40e changes) rather than software-specific,
>> like changes that might be integrated into the helper.
>
> I think there is more commonality amongst hardware capabilities,
> and this is why I want the helper to play itself out.
>
>> That said, I can rework for one helper. The way I see it would be the
>> same code as these patches, as "vxlan_gso_check(struct sk_buff *)" in
>> drivers/net/vxlan.c which would be called from each driver. Is that what
>> you had in mind?
>
> Yes.

Note that this code is not VXLAN specific, it will also accept NVGRE
and GRE/UDP with keyid and TEB. I imagine all these cases should be
indistinguishable to the hardware so they probably just work (which
would be cool!). It might be better to name and locate the helper
function to reflect that.
