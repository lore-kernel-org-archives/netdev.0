From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net-next 3/3] bonding: remove rtmsg_ifinfo called after bond_lower_state_changed
Date: Mon, 23 Oct 2017 23:15:14 +0800
Message-ID: <CADvbK_fbCXbWnhtA9na-ajz5_se4d3d-xEH9PE3d7a9=G-RdDA@mail.gmail.com>
References: <21fdc6d360481b9fffdde8686b9c632b3e207b13.1508755319.git.lucien.xin@gmail.com>
 <201710232254.INLL2XLz%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kbuild-all@01.org, network dev <netdev@vger.kernel.org>,
        davem <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:43768 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbdJWPPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 11:15:16 -0400
Received: by mail-qt0-f196.google.com with SMTP id j58so26580201qtj.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 08:15:15 -0700 (PDT)
In-Reply-To: <201710232254.INLL2XLz%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 10:44 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Xin,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Xin-Long/bonding-void-calling-rtmsg_ifinfo-for-netlink-notifications/20171023-203332
> config: x86_64-rhel (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>>> ERROR: "rtmsg_ifinfo" [net/bridge/bridge.ko] undefined!
sorry, didn't notice bridge is still using rtmsg_ifinfo.

rtmsg_ifinfo actually is no need to be called in br_del_if(),
since patch:
  dc709f3 rtnetlink: bring NETDEV_CHANGEUPPER event process back in
rtnetlink_event

I will propose another patch to remove this.
for this bonding one, I will post v3 without removing rtmsg_ifinfo
export first.
