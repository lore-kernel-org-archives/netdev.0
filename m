From: Josh Boyer <jwboyer@gmail.com>
Subject: Backtrace in rds code
Date: Tue, 24 Jan 2012 16:46:01 -0500
Message-ID: <CA+5PVA7jGq6Hu3ebCzG1FJJStEcsN251Q_0pS9PphkeuAPKxww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51518 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab2AXVqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 16:46:03 -0500
Received: by wics10 with SMTP id s10so3326666wic.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 13:46:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The backtrace below is trivial to trigger, even on a very current Linus tree.
It seems that this was brought up before in November[1], but the conversation
died.

I'm curious if anyone is looking into this issue?  Simply running 'rds-info' is
enough to hit the oops on my machine.

josh

[1] http://thread.gmane.org/gmane.linux.network/211976/focus=212054

[24673.860306] ------------[ cut here ]------------
[24673.860319] WARNING: at kernel/softirq.c:159 local_bh_enable_ip+0xba/0x100()
[24673.860323] Hardware name: XPS 8300
[24673.860326] Modules linked in: rds lockd sunrpc ip6t_REJECT
nf_conntrack_ipv6 nf_conntrack_ipv4 nf_defrag_ipv6 nf_defrag_ipv4
xt_state nf_conntrack ip6table_filter ip6_tables snd_hda_codec_hdmi
snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq
snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc broadcom
dcdbas i2c_i801 microcode iTCO_wdt iTCO_vendor_support tg3 serio_raw
uinput usb_storage uas radeon ttm drm_kms_helper drm i2c_algo_bit
i2c_core [last unloaded: scsi_wait_scan]
[24673.860399] Pid: 23644, comm: rds-info Not tainted
3.3.0-0.rc1.git1.1.fc17.x86_64 #1
[24673.860403] Call Trace:
[24673.860410]  [<ffffffff8106022f>] warn_slowpath_common+0x7f/0xc0
[24673.860416]  [<ffffffff81548570>] ? sock_i_ino+0x40/0x60
[24673.860421]  [<ffffffff8106028a>] warn_slowpath_null+0x1a/0x20
[24673.860426]  [<ffffffff8106836a>] local_bh_enable_ip+0xba/0x100
[24673.860432]  [<ffffffff8169e6b4>] _raw_read_unlock_bh+0x44/0x50
[24673.860437]  [<ffffffff81548570>] sock_i_ino+0x40/0x60
[24673.860444]  [<ffffffffa035a591>] rds_sock_info+0xc1/0x120 [rds]
[24673.860452]  [<ffffffffa035d1b0>] rds_info_getsockopt+0x160/0x200 [rds]
[24673.860459]  [<ffffffffa035a1e3>] rds_getsockopt+0x93/0xf0 [rds]
[24673.860465]  [<ffffffff815475c3>] sys_getsockopt+0x73/0xe0
[24673.860471]  [<ffffffff816a7769>] system_call_fastpath+0x16/0x1b
[24673.860475] ---[ end trace 1aff530051b01526 ]---
