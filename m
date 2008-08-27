From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 16:36:35 +0400
Message-ID: <20080827123635.GA25321@2ka.mipt.ru>
References: <200808220457.40892.denys@visp.net.lb> <48B46B48.7030609@cosmosbay.com> <20080826205158.GA15266@2ka.mipt.ru> <200808271509.18529.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:48299 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753802AbYH0MhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 08:37:00 -0400
Content-Disposition: inline
In-Reply-To: <200808271509.18529.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 03:09:17PM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> On Tuesday 26 August 2008, Evgeniy Polyakov wrote:
> > On Tue, Aug 26, 2008 at 10:44:56PM +0200, Eric Dumazet (dada1@cosmosbay.com) 
> wrote:
> > > >Do you have any packet sockets in this system? Like running dhcp daemon?
> No, nothing at all.

Can you put debug print into
net_enable_timestamp()/net_disable_timestamp() to determine if someone
enabled timestamp socket option?

> tcp        0      0 127.0.0.1:2600          0.0.0.0:*               LISTEN     3167/zebra
> tcp        0      0 0.0.0.0:2601            0.0.0.0:*               LISTEN     3167/zebra
> tcp        0      0 0.0.0.0:2602            0.0.0.0:*               LISTEN     3174/ripd
> tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     3549/sshd
> tcp        0      0 194.146.153.17:22       194.146.154.161:37549   ESTABLISHED11593/sshd
> tcp        0      0 194.146.153.17:22       192.168.0.92:45891      ESTABLISHED11803/sshd
> tcp        0      0 127.0.0.1:42537         127.0.0.1:2600          ESTABLISHED3174/ripd
> tcp        0      0 194.146.153.17:22       194.146.153.18:51810    ESTABLISHED11799/sshd
> tcp        0      0 127.0.0.1:2600          127.0.0.1:42537         ESTABLISHED3167/zebra
> udp        0      0 0.0.0.0:520             0.0.0.0:*                          3174/ripd
> udp        0      0 0.0.0.0:161             0.0.0.0:*                          3194/snmpd
> udp        0      0 0.0.0.0:67              0.0.0.0:*                          3207/udhcpd

This one looks suspicious                                                        ^^^^^^^^^^

> udp   111360      0 0.0.0.0:49619           0.0.0.0:*                          2449/syslogd


-- 
	Evgeniy Polyakov
