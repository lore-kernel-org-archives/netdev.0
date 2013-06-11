From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 02/12] vxlan: fix race between flush and
 incoming learning
Date: Tue, 11 Jun 2013 00:46:17 +0000 (UTC)
Message-ID: <kp5s0p$jv2$1@ger.gmane.org>
References: <20130610200524.721617349@vyatta.com>
 <20130610132456.2333c18b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:57974 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753996Ab3FKAqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 20:46:37 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UmCjM-0008Pm-Fu
	for netdev@vger.kernel.org; Tue, 11 Jun 2013 02:46:36 +0200
Received: from 112.116.154.100 ([112.116.154.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 02:46:36 +0200
Received: from xiyou.wangcong by 112.116.154.100 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 02:46:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jun 2013 at 20:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> It is possible for a packet to arrive during vxlan_stop(), and
> have a dynamic entry created. Close this by checking if device
> is up.
>
>  CPU1                             CPU2   
> vxlan_stop
>   vxlan_flush
>      hash_lock acquired
>                                   vxlan_encap_recv
>                                      vxlan_snoop
>                                         waiting for hash_lock
>      hash_lock relased
>   vxlan_flush done
>                                         hash_lock acquired
>                                         vxlan_fdb_create
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>

This doesn't apply with git am.

% git am /tmp/vxlan-fix-02.diff
Applying: vxlan: fix race between flush and incoming learning
error: patch failed: drivers/net/vxlan.c:632
error: drivers/net/vxlan.c: patch does not apply
Patch failed at 0001 vxlan: fix race between flush and incoming learning
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

But can be applied manually... just fyi.
