From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC v2 net-next 2/2] tcp: Add Redundant Data Bundling
 (RDB)
Date: Mon, 23 Nov 2015 09:43:22 -0800
Message-ID: <1448300602.22599.292.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448295986-14576-1-git-send-email-bro.devel+kernel@gmail.com>
	 <1448295986-14576-3-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?ISO-8859-1?Q?P=E5l?= Halvorsen <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad
	<bro.devel+kernel@gmail.com>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36102 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754970AbbKWRnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 12:43:24 -0500
Received: by pacdm15 with SMTP id dm15so197652343pac.3
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 09:43:24 -0800 (PST)
In-Reply-To: <1448295986-14576-3-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-23 at 17:26 +0100, Bendik R=C3=B8nning Opstad wrote:

> +
> +tcp_rdb_max_skbs - INTEGER
> +	Enable restriction on how many previous SKBs in the output queue
> +	RDB may include data from. A value of 1 will restrict bundling to
> +	only the data from the last packet that was sent.
> +	Default: 1
> +

skb is an internal thing. I would rather not expose a sysctl with such
name.

Can be multi segment or not (if GSO/TSO is enabled)

So even '1' skb can have very different content, from 1 byte to ~64 KB
