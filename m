From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH 1/4] net: consolidate 8021q tagging
Date: Mon, 25 Oct 2010 15:44:45 -0700
Message-ID: <AANLkTikwH39XsWBQXB6YUa6q5YCoT6NXTg1cJAdFfL3n@mail.gmail.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:46950 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab0JYWoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 18:44:46 -0400
Received: by gxk23 with SMTP id 23so2273479gxk.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 15:44:45 -0700 (PDT)
In-Reply-To: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 3:10 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> Now that VLAN packets are tagged in dev_hard_start_xmit()
> at the bottom of the stack we no longer need to tag them
> in the 8021Q module (Except in the !VLAN_FLAG_REORDER_HDR
> case).
>
> This allows the accel path and non accel paths to be consolidated.
> Here the vlan_tci in the skb is always set and we allow the
> stack to add the actual tag in dev_hard_start_xmit().
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

This makes sense.  The only other thing that I would do is drop the
vlan_dev_info(dev)->cnt_encap_on_xmit and
vlan_dev_info(dev)->cnt_inc_headroom_on_tx variables.  Nothing will
ever increment them anymore.
