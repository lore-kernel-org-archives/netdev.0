From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/5 v2] net/cpsw: don't rely only on netif_running() to
 check which device is active
Date: Mon, 22 Apr 2013 14:44:59 +0530
Message-ID: <5174FF93.8070408@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <516FDE0A.70504@ti.com> <516FE2AD.2040403@linutronix.de> <51711E0B.4000306@ti.com> <20130422083048.GA8162@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:50341 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab3DVJQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 05:16:02 -0400
In-Reply-To: <20130422083048.GA8162@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/2013 2:00 PM, Sebastian Andrzej Siewior wrote:
> I tried to describe the reason for that in my patch description. Here
> it is again: netif_running() reports false before ndo_close() has bee=
n
> called. That means an interrupt between the flag change and interrupt
> disabling in ndo_close() will currently lockup the box (IRQ_NONE woul=
d
> at least allow the core to disable the interrupt line).
>
> Initialyly I decided against using IFF_UP as well but using would wor=
k
> without the private active field. So here we have
>
> -v1=E2=80=A6v2: replacing private active field with IFF_UP + netif_ru=
nning()
>
> How about this?
If this is the case, then other Ethernet drivers will also have the sam=
e=20
scenario,
if it can be fixed in a generic way then i will be good.

Regards
Mugunthan V N
