From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 18:17:52 +0800
Message-ID: <BANLkTin6u7VptTm3se_bLdEeTOz2OVc_Rw@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
 <BANLkTinEnHLx1CVh8p0ejLkcaqoLHw2nOA@mail.gmail.com> <20110522093758.GC2611@jirka.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, ebiederm@xmission.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f52.google.com ([209.85.214.52]:61551 "EHLO
	mail-bw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab1EVKSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 06:18:13 -0400
Received: by bwj24 with SMTP id 24so6044758bwj.11
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 03:18:12 -0700 (PDT)
In-Reply-To: <20110522093758.GC2611@jirka.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2011 at 5:37 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>>
>>For a transparent bridge with ports: eth0 and eth1, the vlan tags
>>need to be preserved.
>
> Yet they are - in skb->vlan_tci. I see no problem here. It's the same as
> if the NIC does hw-untagging itself.
>

Although they are in skb->vlan_tci, but the xmit nic, which doesn't
support hw-accel-vlan-tx, doesn't use them to tag the outgoing
packets. Correct me if I am wrong.

I know the current software emulation doesn't strip the vlan headers,
but I want to know in what way you fix the current misuse of
vlan_check_reorder_header(). If you emulation what the HW does
exactly, I am afraid more work are needed. IMHO, this way is more
dangerous than just a revert for this bugfix cycle.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
