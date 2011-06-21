From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 10:08:58 -0700
Message-ID: <20110621100858.70c23a93@nehalam.ftrdhcpuser.net>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, agospoda@redhat.com,
	nhorman@redhat.com, lwoodman@redhat.com
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57429 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756940Ab1FURJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:09:01 -0400
In-Reply-To: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 09:00:40 -0400
Prarit Bhargava <prarit@redhat.com> wrote:

> Add Network Sysrq Support
> 
> In some circumstances, a system can hang/lockup in such a way that the system
> is completely unresponsive to keyboard or console input but is still
> responsive to ping.  The config option, CONFIG_SYSRQ_PING, builds
> net/ipv4/sysrq-ping.ko which allows a root user to configure the system for
> a remote sysrq.
> 
> To use this do:
> 
> mount -t debugfs none /sys/kernel/debug/
> echo 1 > /proc/sys/kernel/sysrq
> echo <hex digit val> > /sys/kernel/debug/network_sysrq_magic
> echo 1 > /sys/kernel/debug/network_sysrq_enable
> 
> Then on another system on the network you can do:
> 
> ping -c 1 -p <up to 30 hex digit val><hex val of sysrq> <target_system_name>
> 
> ex) sysrq-m, m is ascii 0x6d
> 
> ping -c 1 p 1623a06f554d46d676d <target_system_name>
> 
> Note that the network sysrq automatically disables after the receipt of
> the ping, ie) it is single-shot mode.  If you want to use this again, you
> must complete the above four steps again.
> 
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>

Isn't same functionality already available with netconsole?
