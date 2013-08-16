From: Florian Westphal <fw@strlen.de>
Subject: Re: MASQUERADE/SNAT and multiple interfaces with the same IP
Date: Fri, 16 Aug 2013 13:04:43 +0200
Message-ID: <20130816110443.GB5154@breakpoint.cc>
References: <CAKfDRXjXkY--PjXAa1m=As+Vf_1__WBokkTAE5BHg+gxsM9Yxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:32831 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753468Ab3HPLEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 07:04:45 -0400
Content-Disposition: inline
In-Reply-To: <CAKfDRXjXkY--PjXAa1m=As+Vf_1__WBokkTAE5BHg+gxsM9Yxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kristian Evensen <kristian.evensen@gmail.com> wrote:
> After spending long time looking at the source code, I can't figure
> out why this happens. Once the MASQUERADE/SNAT rule has been inserted,
> to me everything looks the same.

The MASQUERADE target zaps conntracks that it "owned" when the
associated link goes down, see masq_device_event() in ipt_MASQUERADE.c

Also, the nat core zaps conntracks when they are sent out on an
interface other than the original interface.

See nf_nat_oif_changed() in iptable_nat.c
