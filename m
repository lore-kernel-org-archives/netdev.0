From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.62] datapath: Add basic MPLS support to kernel
Date: Tue, 24 Jun 2014 16:24:37 -0700
Message-ID: <CAEP_g=9yYqKy-=aiTi3=3cZNOombBgkjHdzLdRzYVVKyJCHqcQ@mail.gmail.com>
References: <1403611017-10965-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>, Thomas Graf <tgraf@suug.ch>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:50062 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753490AbaFXXY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 19:24:58 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so1021586qcw.31
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 16:24:57 -0700 (PDT)
In-Reply-To: <1403611017-10965-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 4:56 AM, Simon Horman <horms@verge.net.au> wrote:
> Allow datapath to recognize and extract MPLS labels into flow keys
> and execute actions which push, pop, and set labels on packets.
>
> Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
>
> Cc: Ravi K <rkerur@gmail.com>
> Cc: Leo Alterman <lalterman@nicira.com>
> Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> Cc: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks for all your work. Time to break out the champagne :)

That being said, I do have a couple of comments for follow up discussion:
 * I removed the addition of MPLS to key_attr_size. This is trying to
calculate the maximum key size and since MPLS will never show up in
conjunction with IPv6 (the current longest key) and isn't longer than
it, MPLS shouldn't increase the maximum size.
 * I think there is a potential for MPLS packets to be incorrectly
offloaded on kernels 3.12-3.15 when encapsulated inside a tunnel. This
is because it won't hit either the OVS GSO code or your enhanced MPLS
feature check. I don't want to lose GSO for tunnels on those kernels
but maybe there is a way to avoid this potential problem without too
much work.
 * Maybe you can refresh my memory - in the case of a push_mpls after
pop_vlan, why can't we do this check correctly for at least one level
of vlan? It seems like we could use the inner EtherType to tell
whether an additional vlan tag is present.
