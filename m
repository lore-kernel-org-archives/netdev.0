From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.17-rc5-mm1
Date: Tue, 30 May 2006 17:59:11 +0200
Message-ID: <6bffcb0e0605300859x5c8f83f5w635fd25f0100fca@mail.gmail.com>
References: <20060530022925.8a67b613.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:25652 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751521AbWE3P7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 11:59:12 -0400
Received: by wr-out-0506.google.com with SMTP id i21so705038wra
        for <netdev@vger.kernel.org>; Tue, 30 May 2006 08:59:11 -0700 (PDT)
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20060530022925.8a67b613.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 30/05/06, Andrew Morton <akpm@osdl.org> wrote:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17-rc5/2.6.17-rc5-mm1/
>
>

It looks like a network stack problem.

May 30 17:50:34 ltg01-fedora init: Switching to runlevel: 6
May 30 17:50:35 ltg01-fedora avahi-daemon[1878]: Got SIGTERM, quitting.
May 30 17:50:35 ltg01-fedora avahi-daemon[1878]: Leaving mDNS
multicast group on interface eth0.IPv4 with address 192.168.0.
14.
May 30 17:50:35 ltg01-fedora kernel:
May 30 17:50:35 ltg01-fedora kernel: ======================================
May 30 17:50:35 ltg01-fedora kernel: [ BUG: bad unlock ordering detected! ]
May 30 17:50:35 ltg01-fedora kernel: --------------------------------------
May 30 17:50:35 ltg01-fedora kernel: avahi-daemon/1878 is trying to
release lock (&in_dev->mc_list_lock) at:
May 30 17:50:35 ltg01-fedora kernel:  [<c02e693b>] ip_mc_del_src+0x5e/0xd5
May 30 17:50:35 ltg01-fedora kernel: but the next lock to release is:
May 30 17:50:35 ltg01-fedora kernel:  (&im->lock){-...}, at:
[<c02e6934>] ip_mc_del_src+0x57/0xd5
May 30 17:50:35 ltg01-fedora kernel:
May 30 17:50:35 ltg01-fedora kernel: other info that might help us debug this:
May 30 17:50:35 ltg01-fedora kernel: 2 locks held by avahi-daemon/1878:
May 30 17:50:35 ltg01-fedora kernel:  #0:  (rtnl_mutex){--..}, at:
[<c02f0b0f>] mutex_lock+0x1c/0x1f
May 30 17:50:35 ltg01-fedora kernel:  #1:
(&in_dev->mc_list_lock){-.-?}, at: [<c02e6905>]
ip_mc_del_src+0x28/0xd5
May 30 17:50:35 ltg01-fedora kernel:
May 30 17:50:35 ltg01-fedora kernel: stack backtrace:
May 30 17:50:35 ltg01-fedora kernel:  [<c0103e52>] show_trace_log_lvl+0x4b/0xf4
May 30 17:50:35 ltg01-fedora kernel:  [<c01044b3>] show_trace+0xd/0x10
May 30 17:50:35 ltg01-fedora kernel:  [<c010457b>] dump_stack+0x19/0x1b
May 30 17:50:35 ltg01-fedora kernel:  [<c0139bfa>] lockdep_release+0x18b/0x350
May 30 17:50:35 ltg01-fedora kernel:  [<c02f2640>] _read_unlock+0x16/0x4d
May 30 17:50:35 ltg01-fedora kernel:  [<c02e693b>] ip_mc_del_src+0x5e/0xd5
May 30 17:50:35 ltg01-fedora kernel:  [<c02e69de>] ip_mc_leave_src+0x2c/0x6c
May 30 17:50:35 ltg01-fedora kernel:  [<c02e6c5b>] ip_mc_leave_group+0x3d/0x97
May 30 17:50:35 ltg01-fedora kernel:  [<c02c8a68>] ip_setsockopt+0x4d0/0x9a6
May 30 17:50:35 ltg01-fedora kernel:  [<c02def6d>] udp_setsockopt+0x1f/0x9c
May 30 17:50:35 ltg01-fedora kernel:  [<c02a7006>]
sock_common_setsockopt+0x13/0x18
May 30 17:50:35 ltg01-fedora kernel:  [<c02a5956>] sys_setsockopt+0x73/0xa4
May 30 17:50:35 ltg01-fedora kernel:  [<c02a6c53>] sys_socketcall+0x148/0x186
May 30 17:50:35 ltg01-fedora kernel:  [<c02f2ad5>] sysenter_past_esp+0x56/0x8d

Here is config
http://www.stardust.webpages.pl/files/mm/2.6.17-rc5-mm1/mm-config

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
