From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Add missing read memory barrier to Intel Ethernet device
	drivers
Date: Wed, 21 Jul 2010 13:28:01 -0700
Message-ID: <AANLkTikthaM7SmAhC0iw2A5dscoGugOACdzCVReu=x0W@mail.gmail.com>
References: <20100721162241.GW21853@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Sonny Rao <sonnyrao@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:42502 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab0GUU2D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:28:03 -0400
Received: by iwn7 with SMTP id 7so7068485iwn.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:28:01 -0700 (PDT)
In-Reply-To: <20100721162241.GW21853@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 09:22, Sonny Rao <sonnyrao@us.ibm.com> wrote:
> From: Milton Miller <miltonm@bga.com>
>
> The PowerPC architecture does not require loads to independent bytes =
to be
> ordered without adding an explicit barrier.
>
> In ixgbe_clean_rx_irq we load the status bit then load the packet dat=
a.
> With packet split disabled if these loads go out of order we get a
> stale packet, but we will notice the bad sequence numbers and drop it=
=2E
>
> The problem occurs with packet split enabled where the TCP/IP header =
and data
> are in different descriptors. If the reads go out of order we may hav=
e data
> that doesn't match the TCP/IP header. Since we use hardware checksumm=
ing this
> bad data is never verified and it makes it all the way to the applica=
tion.
>
> This bug was found during stress testing and adding this barrier has =
been shown
> to fix it. =C2=A0The bug can manifest as a data integrity issue (bad =
payload data)
> or as a BUG in skb_pull().
>
> This was a nasty bug to hunt down, if people agree with the fix I thi=
nk
> it's a candidate for stable.
>
> Previously Submitted to e1000-devel only for ixgbe
>
> http://marc.info/?l=3De1000-devel&m=3D126593062701537&w=3D3
>
> We've now seen this problem hit with other device drivers (e1000e mos=
tly)
> So I'm resubmitting with fixes for other Intel Device Drivers with
> similar issues: =C2=A0ixgb, e100, e1000, and e1000e
>
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Sonny Rao <sonnyrao@us.ibm.com>
> cc: stable <stable@kernel.org>
>

Thanks Milton, I have added the patch to my queue.

--=20
Cheers,
Jeff
