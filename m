From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [RFC PATCH 4/5] bnxt: Add support for segmentation of tunnels
 with outer checksums
Date: Fri, 29 Apr 2016 16:29:13 -0700
Message-ID: <CACKFLik68GedLctO9cXoBZSrFR6RnRkCprn3h=xmBwn3-uojLg@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
	<20160419190615.11723.53966.stgit@ahduyck-xeon-server>
	<CACKFLi=2mHfOS1Rz5RbSdyhepdjBqM+dj7Nh=CzARcYSwUTcSw@mail.gmail.com>
	<CAKgT0UffVkQWWqgwYZy-AXEq=kofKiRx2D9pnu5nBQD+uSLS+g@mail.gmail.com>
	<CACKFLi=0ug=E++9prBjC7NsD67+DtLKXXwFtF-E0+trVNtMgbA@mail.gmail.com>
	<CAKgT0UeOPX22XipaSUsCgZ9oPsw1Q6KWGoEA+rpjANp6RQ+gnA@mail.gmail.com>
	<CACKFLinpYTDTxzBaijdSTE9q+5Ln4Sbo5fGxRbY+wv6bwP=vOQ@mail.gmail.com>
	<CAKgT0Ud3DWAB+se3nH2Ub+LB+UeMssyFkD=qaBdU3F6_E3u2-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35983 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbcD2X3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 19:29:14 -0400
Received: by mail-oi0-f45.google.com with SMTP id x201so135663765oif.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 16:29:13 -0700 (PDT)
In-Reply-To: <CAKgT0Ud3DWAB+se3nH2Ub+LB+UeMssyFkD=qaBdU3F6_E3u2-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 2:31 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:

> Okay so if that is the case we may want to make it so that we ignore
> checksum for both IPv4 and IPv6 and then we can just provide it via
> GSO_PARTIAL in the case we want it.  Otherwise you are technically
> mangling the frames by inserting a checksum on the outer header even
> though the tunnel was not configured for it.  If you can point me
> toward the point in the code where that is happening I can probably
> make it a part of this patch.
>

All the chip settings are controlled by firmware.  I will check with
the firmware team to disable them if they are not already disabled.
When first developing the driver, before all the recent proposals, the
intention was to not advertise NETIF_F_GSO_UDP_TUNNEL_CSUM and not
support TSO with outer UDP checksum enabled.  Thanks.
