From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 4.9-rc7: (forcedeth?) BUG: sleeping function called from
 invalid context at kernel/irq/manage.c:110
Date: Tue, 29 Nov 2016 11:58:15 -0800
Message-ID: <1480449495.18162.152.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LRH.2.20.1611292222200.31348@math.ut.ee>
         <CAADWXX8GM5Xdf1Of09ABXEB8eb=eVqPjHTaT7ZzcStnX8=cO_A@mail.gmail.com>
         <alpine.LRH.2.20.1611292309490.31348@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux Kernel list <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.20.1611292309490.31348@math.ut.ee>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-11-29 at 23:16 +0200, Meelis Roos wrote:
> > On Tue, Nov 29, 2016 at 12:26 PM, Meelis Roos <mroos@linux.ee> wrote:
> > > This is 4.9-rc7 on Sun Ultra 20 (Opteron 175 on NVidia chipset PC with
> > > NVidia ethernet).
> > >
> > > BUG: sleeping function called from invalid context at kernel/irq/manage.c:110
> > 
> > Hmm. No changes in either forcedeth or in the synchronize_irq() debugging.
> [...]
> > But none of this looks new. I don't see _anything_ in any of these
> > areas that has changed since 4.8.
> > 
> > Which is why I suspect you changed something in your setup wrt
> > netconsole or your kernel config?
> 
> No changes that I could see. Only answered oldconfig questions, diff 
> below. /etc/default/grub is from May so not changed recently. Just 
> verified that 4.8.0 dmesg did not contain these warnings.
> 
> Conf diff and current config are below:

nv_do_nic_poll() is simply buggy and needs a fix.

synchronize_irq() can sleep.
