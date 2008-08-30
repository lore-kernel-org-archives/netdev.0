From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 2/2] ne.c msleep not mdelay
Date: Sat, 30 Aug 2008 23:36:47 +0900 (JST)
Message-ID: <20080830.233647.05599714.anemo@mba.ocn.ne.jp>
References: <20080830024453.GB24929@spacedout.fries.net>
	<20080830095906.6cad8647@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david@fries.net, linux-kernel@vger.kernel.org,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753869AbYH3Og7@vger.kernel.org>
In-Reply-To: <20080830095906.6cad8647@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Aug 2008 09:59:06 +0100, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > mdelay(10) replaced by msleep(10) to give up the CPU, it's just
> > waiting for an interrupt, so timing isn't critical.
> 
> It is too critical for a reschedule to occur.
> 
> NAK this one.

There are already some msleep() in probe_irq_on() which is called just
before here.  And this part is not protected by any spinlock or
preempt_disable.

So, if rescheduling was dangerous here, we already have potential
problems, no?

---
Atsushi Nemoto
