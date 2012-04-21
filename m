From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2] macvlan/macvtap: Fix vlan tagging on user read
Date: Fri, 20 Apr 2012 18:51:51 -0700
Message-ID: <m1d371zwaw.fsf@fess.ebiederm.org>
References: <1334964058-3338-1-git-send-email-basilgor@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Basil Gor <basilgor@gmail.com>
To: Basil Gor <basil.gor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46152 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863Ab2DUBru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 21:47:50 -0400
In-Reply-To: <1334964058-3338-1-git-send-email-basilgor@gmail.com> (Basil
	Gor's message of "Sat, 21 Apr 2012 03:20:58 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basil Gor <basil.gor@gmail.com> writes:

> Vlan tag is restored during buffer transmit to a network device (bridge
> port) in bridging code in case of tun/tap driver. In case of macvtap it
> has to be done explicitly. Otherwise vlan_tci is ignored and user always
> gets untagged packets.
>
> Scenario tested:
> kvm guests (that use vlans) migration from bridged network to macvtap
> revealed that packets delivered to guests are always untagged. Dumping
> and comparing sk_buff in case of tap and macvtap driver showed that
> macvtap does not restore vlan_tci.
>
> With current patch applied I was able to get working network, kvm guests
> get correctly tagged packets and can reach each other when macvtap in
> bridge mode (both with no vlans and through vlan interfaces).
>
> Changes from original version:
> vlan header restoring code is moved from macvtap_forward to
> macvtap_receive

I really think this is the wrong fix.

Eric
