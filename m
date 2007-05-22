From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: TCP_MD5 and Intel e1000
Date: Tue, 22 May 2007 18:36:47 +0900 (JST)
Message-ID: <20070522.183647.75785266.yoshfuji@linux-ipv6.org>
References: <C2786969.24B46%webmaster@poweraudio.de>
	<20070522105738.f03cb83b.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: webmaster@poweraudio.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32771 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827AbXEVJgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 05:36:49 -0400
In-Reply-To: <20070522105738.f03cb83b.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070522105738.f03cb83b.dada1@cosmosbay.com> (at Tue, 22 May 2007 10:57:38 +0200), Eric Dumazet <dada1@cosmosbay.com> says:

> > I have tried to set up quagga with tcp-md5 support from kernel. All seems ok
> > with a intel e100 NIC, but as i testetd with a intel e1000 NIC the tcp
> > packets have an invalid md5 digest.
> > If i run tcpdump on the mashine the packets are generated, it shows on the
> > outgoing interface invalid md5 digests.
> > Are there known issues about tcp-md5 and e1000 NICs?
:
> You could try "ethtool -K tx off", and/or other ethtool -K settings

Disabling offloading should help; currently tcp-md5 stack
blindly copy md5-signature from the first segment
which is not appropriate for rest of segments.

--yoshfuji
