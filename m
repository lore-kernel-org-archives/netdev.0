From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Ingress tc filters with IPSec
Date: Sat, 30 May 2015 02:24:51 -0400
Message-ID: <1432967091.4289.12.camel@jasiiieee.pacifera.com>
References: <1432965132.4289.10.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.196]:50782 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238AbbE3GYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2015 02:24:55 -0400
Received: from [192.168.1.3] ([69.116.52.45]) by mrelay.perfora.net
 (mreueus001) with ESMTPSA (Nemesis) id 0M4Yxu-1ZJXMQ0WxI-00ydzi for
 <netdev@vger.kernel.org>; Sat, 30 May 2015 08:24:54 +0200
In-Reply-To: <1432965132.4289.10.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-05-30 at 01:52 -0400, John A. Sullivan III wrote:
> Argh! yet another obstacle from my ignorance.  We are attempting ingress
> traffic shaping using IFB interfaces on traffic coming via GRE / IPSec.
> Filters and hash tables are working fine with plain GRE including
> stripping the header.  We even got the ematch filter working so that the
> ESP packets are the only packets not redirected to IFB.
> 
> But, regardless of whether we redirect ESP packets to IFB, the filters
> never see the decrypted packets.  I thought the packets passed through
> the interface twice - first encrypted and they decrypted.  However,
> tcpdump only shows the ESP packets on the interface.
> 
> How do we apply filters to the packets after decryption? Thanks - John

I see what changed.  In the past, this seemed to work but we were using
tunnel mode.  We were trying to use transport mode in this application
but that seems to prevent the decrypted packet contents from appearing
again on the interface.  Reverting to tunnel mode made the contents
visible again and our filters are working as expected - John
