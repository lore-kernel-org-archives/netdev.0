From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]  bridge: per-cpu packet statistics (v2)
Date: Tue, 02 Mar 2010 19:06:13 +0100
Message-ID: <1267553173.2839.9.camel@edumazet-laptop>
References: <20100301161658.5a61143b@nehalam>
	 <1267520579.2964.27.camel@edumazet-laptop>
	 <20100302095831.151c8bb5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:56595 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab0CBSGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 13:06:17 -0500
Received: by bwz1 with SMTP id 1so119773bwz.21
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 10:06:16 -0800 (PST)
In-Reply-To: <20100302095831.151c8bb5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 02 mars 2010 =C3=A0 09:58 -0800, Stephen Hemminger a =C3=A9cri=
t :
> +	struct br_cpu_netstats __percpu {
> +		unsigned long	rx_packets;
> +		unsigned long	tx_packets;
> +		unsigned long	rx_bytes;
> +		unsigned long	tx_bytes;
> +	} *stats;
> +

Ok, please group rx stats together instead of interleave, this to reduc=
e
possibility of touching two cache lines in tx path (or rx path)

	struct br_cpu_netstats __percpu {
> 		unsigned long	rx_packets;
> +		unsigned long	rx_bytes;
>=20
> +		unsigned long	tx_packets;
> +		unsigned long	tx_bytes;
> +	} *stats;
> +


