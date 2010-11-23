From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] via-rhine: hardware VLAN support
Date: Mon, 22 Nov 2010 18:02:04 -0800
Message-ID: <AANLkTinD7fTvX4yfVWJs4oxx6fYA0m5snct6d+qFUg8D@mail.gmail.com>
References: <20101105104303.GA8325@core.hellgate.ch>
	<AANLkTikUe9DR2QTU+72Q8vmGnDyvUtSm_wwCpGEq-M4s@mail.gmail.com>
	<20101108162132.GA32728@core.hellgate.ch>
	<AANLkTim40QH2AWz8YtW_y3=WjEU0_Rom9-CPFj-O5MCt@mail.gmail.com>
	<20101121131756.GA18509@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48904 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab0KWCCG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 21:02:06 -0500
Received: by fxm13 with SMTP id 13so3339516fxm.19
        for <netdev@vger.kernel.org>; Mon, 22 Nov 2010 18:02:04 -0800 (PST)
In-Reply-To: <20101121131756.GA18509@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 21, 2010 at 5:17 AM, Roger Luethi <rl@hellgate.ch> wrote:
> On Mon, 08 Nov 2010 12:53:57 -0800, Jesse Gross wrote:
>> On Mon, Nov 8, 2010 at 8:21 AM, Roger Luethi <rl@hellgate.ch> wrote:
>> > On Fri, 05 Nov 2010 11:31:56 -0700, Jesse Gross wrote:
>> > Can you point me to a driver that has been switched to use the new=
 methods
>> > already? Is there some other form of documentation?
>>
>> bnx2 is an example of a driver that has been converted. =A0The commi=
t
>> that actually made the change was
>> 7d0fd2117e3d0550d7987b3aff2bfbc0244cf7c6, which should highlight the
>> differences. =A0A key point is that drivers should no longer referen=
ce
>> vlan groups at all.
>
> bnx2 does not support hardware VLAN filters, but ixgbe does (converte=
d by
> commit f62bbb5e62c6e4a91fb222d22bc46e8d4d7e59ef). ixgbe keeps a list =
of
> configured VLANs in a device private data structure (active_vlans). I=
s that
> the model to follow?

Yes, that's right.  The driver should store whatever information it
requires to manage the CAM or restore the state after a board reset.
