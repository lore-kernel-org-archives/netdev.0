From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Wed, 24 Mar 2004 13:33:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040324133339.A23643@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp> <20040323195119.A14062@electric-eye.fr.zoreil.com> <871xnjgwrs.fsf@devron.myhome.or.jp> <20040324014140.A16202@electric-eye.fr.zoreil.com> <87lllrdkiu.fsf@ibmpc.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Content-Disposition: inline
In-Reply-To: <87lllrdkiu.fsf@ibmpc.myhome.or.jp>; from hirofumi@mail.parknet.co.jp on Wed, Mar 24, 2004 at 11:52:09AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[...]
> Do you care the lost interrupt? If so, I was miss reading it.
> 
> IIRC, PCI spec requires the level-trigger. So devices asserts IRQ
> signal until the driver clears the pending interrupt. No?

<insert usual "correct me if I'm wrong" disclaimer here>

The driver only masks the interruptions which are napi related so
epic_poll() and epic_interrupt() are always racing. I completely agree that
it "wastes" the nice behavior of level-triggered irq. If one wants to avoid
the race, everything should go to the poll() handler. It implies polled
access to the INTSTAT register (as done in epic_rx_err).

I could not find in the archives some general napi-wisdom which suggests
that everything has to go to the poll() handler, be it for simplicity or
for a real gain. So I hesitate to follow the other way and exchange the
polled access for some (locked) traffic between the poll() and the irq
handler.

Comments welcome.

--
Ueimor
