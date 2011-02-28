From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net-next: warnings from sysctl_net_exit
Date: Sun, 27 Feb 2011 16:08:52 -0800
Message-ID: <20110227160852.4f748c1f@nehalam>
References: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47089 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833Ab1B1AIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Feb 2011 19:08:55 -0500
In-Reply-To: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Feb 2011 00:37:09 +0200
Lucian Adrian Grijincu <lucian.grijincu@gmail.com> wrote:

> Stephen Hemminger <shemminger <at> vyatta.com> writes:
> > [26207.669740]  [<ffffffff814154ad>] ? sysctl_net_exit+0x2a/0x2c
> > [26207.669742]  [<ffffffff8136144e>] ? ops_exit_list+0x2a/0x5b
> > [26207.669745]  [<ffffffff813618f0>] ? cleanup_net+0xfa/0x19a
> 
> 
> David: it looks like someone registered a /proc/sys table with
> register_net_sysctl_table but forgot to remove it (or someone wrote
> something in the 'struct net*' and buffer overflowed into
> &net->sysctls.list).
> 
> Stephen, can you post a `ls -R /proc/sys/net/` from before the dmesg
> message appeared?
> 
> The check is triggered at network namespace deletion, so a moment
> before deleting the netns should be fine.

Although the kernel was compiled with netns, I never use net namespaces.
