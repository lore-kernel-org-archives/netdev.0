From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 4/4] vxlan: implement GPE
Date: Wed, 16 Mar 2016 18:38:10 +0100
Message-ID: <20160316183810.43eb3f3b@griffin>
References: <cover.1458146189.git.jbenc@redhat.com>
	<dfd48851882518164e289feaf43930d9a9e038b3.1458146189.git.jbenc@redhat.com>
	<CALx6S37n=4-VUTOx7cZuAaVOFa4=wtGgd7iBwAk8pMNmpt_vcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933580AbcCPRiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 13:38:13 -0400
In-Reply-To: <CALx6S37n=4-VUTOx7cZuAaVOFa4=wtGgd7iBwAk8pMNmpt_vcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2016 10:31:10 -0700, Tom Herbert wrote:
> Sorry, I still don't like this. For VXLAN-GPE packets the above two
> conditionals are a complete waste of time and I shouldn't have to go
> pawing through configuration to determine what protocol has actually
> be implemented.  Please, at least move these into the else block of
> "if (vs->flags & VXLAN_F_GPE) {" above. This saves two conditionals in
> the data path, makes the parsing code more readable, and you don't
> need to reference configuration to figure things out.

As I already wrote, this is not possible. GPE parsing needs to occur
before iptunnel_pull_header (because we need to know the protocol), GBP
parsing needs to happen after it (after udp_tun_rx_dst specifically).

Believe me, I would do it that way if it was possible.

I also considered splitting rx path for GPE and non-GPE case and the
result was much uglier and longer code.

 Jiri
