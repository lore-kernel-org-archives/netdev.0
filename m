From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Mon, 3 Jan 2011 10:47:20 -0800
Message-ID: <AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:51890 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab1ACSrY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 13:47:24 -0500
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p03IlMB8018990
	for <netdev@vger.kernel.org>; Mon, 3 Jan 2011 10:47:23 -0800
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz5.hot.corp.google.com with ESMTP id p03IlKQi001033
	for <netdev@vger.kernel.org>; Mon, 3 Jan 2011 10:47:21 -0800
Received: by pzk5 with SMTP id 5so3760004pzk.31
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 10:47:20 -0800 (PST)
In-Reply-To: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure why this would be needed.  What is the a advantage in
making the TX and RX queues match?

On Fri, Dec 17, 2010 at 5:00 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> This patch series is meant to be a proof of concept for simplifying t=
he cost
> of Toeplitz hashing by reducing the complexity of the key to a 16 bit
> repeating value. =A0The resultant advantages are that the hash comput=
ation
> performance is significantly increased, and that the resultant hash i=
s the
> same for flows in either direction.
>
> The idea for this occurred to me while working on the ATR hashing alg=
orithms
> and improving their performance. =A0ATR implements a 32 bit repeating=
 key which
> results in us being able to XOR everything down to a 32 bit value. =A0=
By using a
> 16 bit key we are able to cut down the 12 to 36 byte input value to o=
nly 2
> bytes via XOR operations. =A0This reduces the resultant hash to 16 bi=
ts, however
> since queue selection only requires 7 bits for RSS that still leaves =
us with a
> large enough resultant key.
>
> I'm currently not planning to do any more work on this in the near fu=
ture as I
> have several other projects in which I am currently engaged. =A0Howev=
er I just
> wanted to put this code out there in case anyone had a use for it.
>
> Thanks,
>
> Alex
>
> ---
>
> Alexander Duyck (3):
> =A0 =A0 =A0igb: example of how to update igb to make use of in-kernel=
 Toeplitz hashing
> =A0 =A0 =A0ixgbe: example of how to update ixgbe to make use of in-ke=
rnel Toeplitz hash
> =A0 =A0 =A0net: add simplified 16 bit Toeplitz hash function for tran=
smit side hashing
>
>
> =A0drivers/net/igb/igb_main.c =A0 =A0 | =A0 22 ++++------
> =A0drivers/net/ixgbe/ixgbe_main.c | =A0 47 ++++++++++++---------
> =A0include/linux/netdevice.h =A0 =A0 =A0| =A0 =A02 +
> =A0include/linux/toeplitz.h =A0 =A0 =A0 | =A0 89 ++++++++++++++++++++=
++++++++++++++++++++
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 68 ++++++++++=
+++++++++++++++++++++
> =A05 files changed, 195 insertions(+), 33 deletions(-)
> =A0create mode 100644 include/linux/toeplitz.h
>
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
