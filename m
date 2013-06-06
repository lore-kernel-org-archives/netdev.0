From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] vxlan: fix crash on module removal
Date: Thu, 6 Jun 2013 01:11:11 +0000 (UTC)
Message-ID: <koonje$ssv$1@ger.gmane.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
 <1370406254-6341-3-git-send-email-stephen@networkplumber.org>
 <20130605083700.2a09e379@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44208 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222Ab3FFBL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 21:11:29 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UkOjg-0001HX-63
	for netdev@vger.kernel.org; Thu, 06 Jun 2013 03:11:28 +0200
Received: from 222.221.58.58 ([222.221.58.58])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 03:11:28 +0200
Received: from xiyou.wangcong by 222.221.58.58 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 03:11:28 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jun 2013 at 15:37 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> If vxlan is removed with active vxlan's it would crash because
> rtnl_link_unregister (which calls vxlan_dellink), was invoked
> before unregister_pernet_device (which calls vxlan_stop).
>

Two points:

1. There are still many others drivers calling them in such order...
2. The removal should be in a reverse order of creation, at least in
theory.

I mean this *might* indicate something wrong.
