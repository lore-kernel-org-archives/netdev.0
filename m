From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC Patch v2] net: reserve ports for applications using fixedport numbers
Date: Fri, 5 Feb 2010 20:21:28 +0900
Message-ID: <201002052021.CIC81776.QVSMJOLtFOFFHO@I-love.SAKURA.ne.jp>
References: <20100204101533.4619.34599.sendpatchset@localhost.localdomain>
	<201002041959.JEG43202.JQOFHFOVSFMtLO@I-love.SAKURA.ne.jp>
	<4B6BA16E.3010002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, davem@davemloft.net
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:63665 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754938Ab0BELVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 06:21:35 -0500
In-Reply-To: <4B6BA16E.3010002@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> Oh, IIUC, TOMOYO is something like SELinux?

Yes. It is a policy based mandatory access control implementation which is
applied to not only non root users but also root user. If MAC is enabled,
root user cannot freely modify via sysctl() or /proc/sys interface.

> So, it is somewhat weird to let users to use TOMOYO to reserve
> the ports with MAC.

To add reserved port

echo deny_autobind 0-1023 | ccs-loadpolicy -e
echo deny_autobind 3128 | ccs-loadpolicy -e
echo deny_autobind 8080 | ccs-loadpolicy -e

and to delete reserved port

echo delete deny_autobind 0-1023 | ccs-loadpolicy -e
echo delete deny_autobind 3128 | ccs-loadpolicy -e
echo delete deny_autobind 8080 | ccs-loadpolicy -e

That's all. Quite easy.

> For normal users /proc interface seems more friendly.

I think /proc/sys/net/ipv4/ip_local_reserved_ports interface wants
"struct list_head" for handling multiple sets of min/max pairs. I'm using
http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/security/ccsecurity/autobind.c#L29
for that purpose.
