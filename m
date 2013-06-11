From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 03/12] vxlan: move IGMP join/leave to work queue
Date: Tue, 11 Jun 2013 02:01:32 +0000 (UTC)
Message-ID: <kp60dr$rn$3@ger.gmane.org>
References: <20130610200524.721617349@vyatta.com>
 <20130610132454.50e93226@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:55964 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437Ab3FKCKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 22:10:04 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UmE27-0006q1-Ch
	for netdev@vger.kernel.org; Tue, 11 Jun 2013 04:10:03 +0200
Received: from 112.116.154.100 ([112.116.154.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 04:10:03 +0200
Received: from xiyou.wangcong by 112.116.154.100 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 04:10:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jun 2013 at 20:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> Do join/leave from work queue to avoid lock inversion problems
> between normal socket and RTNL. The code comes out cleaner
> as well.
>
> Uses Cong Wang's suggestion to turn refcnt into a real atomic
> since now need to handle case where last use of socket is IGMP
> worker.
>
> Also fixes race where vxlan_stop could be called after
> device was deleted on module removal. The call to rtnl_link_unregister
> would call dellink while vxlan device was still up. Reordering
> the calls fixes it.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>

Tested-by: Cong Wang <xiyou.wangcong@gmail.com>
Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
