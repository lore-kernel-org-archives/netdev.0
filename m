From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH (net.git) 2/4] stmmac: fix and better tune the default
 buffer sizes
Date: Thu, 27 Feb 2014 10:51:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CC945@AcuExch.aculab.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com>
 <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Giuseppe Cavallaro' <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33932 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750993AbaB0Kwa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:52:30 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05025-01 for <netdev@vger.kernel.org>;
 Thu, 27 Feb 2014 10:52:29 +0000 (GMT)
In-Reply-To: <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro
> This patch is to fix and tune the default buffer sizes.
> It reduces the default bufsize used by the driver from
> 2048 to 1518 (taking into account the extra 4 bytes in case of VLAN).
...
> -#define DMA_BUFFER_SIZE	BUF_SIZE_4KiB
> -static int buf_sz = DMA_BUFFER_SIZE;

Does this means that the old default was 4k, not the 2k in the
patch description.

> +#ifdef STMMAC_VLAN_TAG_USED
> +#define	DEFAULT_BUFSIZE	(VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
> +#else
> +#define	DEFAULT_BUFSIZE	(ETH_FRAME_LEN + ETH_FCS_LEN)
> +#endif
...
> +	if (unlikely((buf_sz < DEFAULT_BUFSIZE) || (buf_sz > BUF_SIZE_16KiB)))
> +		buf_sz = DEFAULT_BUFSIZE;

It doesn't seem right to me for the minimum buffer size to
depend on a compile-time option for VLAN.

Also (provided the hardware supports it) the rx buffers (are these
the ones being sized?) need to be aligned on a 4n+2 boundary in
order to avoid a realignment copy later on.
So I'm not sure that some of these sizes are right and/or optimal.

	David
