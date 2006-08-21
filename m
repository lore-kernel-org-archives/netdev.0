From: Daniel Drake <dsd@gentoo.org>
Subject: Re: sky2 driver - large files upload problem
Date: Mon, 21 Aug 2006 14:18:04 +0100
Message-ID: <44E9B28C.9050207@gentoo.org>
References: <44E9A9E0.20106@cheetah.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:10611 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030445AbWHUNGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 09:06:38 -0400
To: Jon Wikne <wikne@cheetah.uio.no>
In-Reply-To: <44E9A9E0.20106@cheetah.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon,

Jon Wikne wrote:
> What happens is typically this: After transeferring some
> data, ranging from less than 100kB to 10MB, the upload freezes,
> i.e. gets no further. Use of ping shows the connection is
> effectively dead. If I do a sequence /sbin/ifdown eth0
> /sbin/ifup eth0 the upload might resume, but stops again
> shortly. The phenomenon seems to occur sooner if the path
> to the remote system is _fast_ (low ping times).

You can try applying this patch:
http://developer.osdl.org/shemminger/prototypes/sky2-proc-debug.patch

It will add a /proc/net/sky2/ethX file, which lists the status of the TX 
and status rings. You should compare the contents of this file during 
normal operation to when the interface has hung.

Daniel
