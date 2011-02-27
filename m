From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: net-next: warnings from sysctl_net_exit
Date: Mon, 28 Feb 2011 00:37:09 +0200
Message-ID: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:33509 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab1B0Wh3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 17:37:29 -0500
Received: by iwn34 with SMTP id 34so2608218iwn.19
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 14:37:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger <at> vyatta.com> writes:
> [26207.669740]  [<ffffffff814154ad>] ? sysctl_net_exit+0x2a/0x2c
> [26207.669742]  [<ffffffff8136144e>] ? ops_exit_list+0x2a/0x5b
> [26207.669745]  [<ffffffff813618f0>] ? cleanup_net+0xfa/0x19a


David: it looks like someone registered a /proc/sys table with
register_net_sysctl_table but forgot to remove it (or someone wrote
something in the 'struct net*' and buffer overflowed into
&net->sysctls.list).

Stephen, can you post a `ls -R /proc/sys/net/` from before the dmesg
message appeared?

The check is triggered at network namespace deletion, so a moment
before deleting the netns should be fine.


--=20
=C2=A0.
=2E.: Lucian
