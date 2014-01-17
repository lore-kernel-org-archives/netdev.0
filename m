From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Fri, 17 Jan 2014 09:30:24 -0800
Message-ID: <CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:49832 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbaAQRaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 12:30:25 -0500
Received: by mail-ob0-f176.google.com with SMTP id gq1so2579822obb.7
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 09:30:24 -0800 (PST)
In-Reply-To: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 3:55 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> -       if (event == NETDEV_UNREGISTER)
> +       if (event == NETDEV_UNREGISTER) {
> +               vn = net_generic(dev_net(dev), vxlan_net_id);
>                 vxlan_handle_lowerdev_unregister(vn, dev);
> +       }

There is no need to keep vxlan_handle_lowerdev_unregister(),
it is too short. So, just use my patch.
