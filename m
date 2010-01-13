From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v4] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Wed, 13 Jan 2010 16:13:46 -0500
Message-ID: <4B4E378A.7040506@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com> <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com> <20100113155323.GB24818@basil.fritz.box> <4B4E23E0.4000007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756416Ab0AMVNv@vger.kernel.org>
In-Reply-To: <4B4E23E0.4000007@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I did today's tests on tcp_ipv4, but part of this harmonization is to
make v4 and v6 match up better.  As I was examining line by line, one of
the things that leaps out is that ipv4 has nf_reset(skb):

tcp_ipv4:
	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
		goto discard_and_relse;
	nf_reset(skb);

	if (sk_filter(sk, skb))
		goto discard_and_relse;

tcp_ipv6:
	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
		goto discard_and_relse;

	if (sk_filter(sk, skb))
		goto discard_and_relse;

Does anybody know why?  Should ipv6 have it?  Or at least a comment
explaining the reasoning for the omission?
