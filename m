From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 2/9] net-ethtool: Convert (hw_/vlan_/wanted_)features
 fields from u32 type to u64.
Date: Mon, 25 Apr 2011 10:48:52 +0200
Message-ID: <BANLkTikjhY-M7ZB8azYctq9p1ORmA8PBKQ@mail.gmail.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com> <1303515367-25595-3-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38730 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757064Ab1DYItN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 04:49:13 -0400
Received: by qwk3 with SMTP id 3so877496qwk.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 01:49:12 -0700 (PDT)
In-Reply-To: <1303515367-25595-3-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/23 Mahesh Bandewar <maheshb@google.com>:
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> =C2=A0include/linux/ethtool.h | =C2=A0 26 +++++++------
> =C2=A0net/core/ethtool.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 89 ++++++++++++=
++++------------------------------
> =C2=A02 files changed, 45 insertions(+), 70 deletions(-)
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 9de3127..71e8a02 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -605,10 +605,10 @@ struct ethtool_flash {
> =C2=A0* @never_changed: mask of features not changeable for any devic=
e
> =C2=A0*/
> =C2=A0struct ethtool_get_features_block {
> - =C2=A0 =C2=A0 =C2=A0 __u32 =C2=A0 available;
> - =C2=A0 =C2=A0 =C2=A0 __u32 =C2=A0 requested;
> - =C2=A0 =C2=A0 =C2=A0 __u32 =C2=A0 active;
> - =C2=A0 =C2=A0 =C2=A0 __u32 =C2=A0 never_changed;
> + =C2=A0 =C2=A0 =C2=A0 __u64 =C2=A0 available;
> + =C2=A0 =C2=A0 =C2=A0 __u64 =C2=A0 requested;
> + =C2=A0 =C2=A0 =C2=A0 __u64 =C2=A0 active;
> + =C2=A0 =C2=A0 =C2=A0 __u64 =C2=A0 never_changed;
> =C2=A0};
[...]

Please don't do it like this. G/SFEATURES were prepared to handle
multiple words when needed. This means that it's enough to just split
the u64 into two u32 sets represented in ethtool_get/set_features.

Best Regards,
Micha=C5=82 Miros=C5=82aw
