From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Net module Realtek 8110S/8169S
Date: Mon, 29 Mar 2004 01:24:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329012458.A24996@electric-eye.fr.zoreil.com>
References: <HVAV6J$519DA0EE0F55619EB1C716E4E68CA99E@libero.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "markes.albert@libero.it" <markes.albert@libero.it>
Content-Disposition: inline
In-Reply-To: <HVAV6J$519DA0EE0F55619EB1C716E4E68CA99E@libero.it>; from markes.albert@libero.it on Sun, Mar 28, 2004 at 08:54:19PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

markes.albert@libero.it <markes.albert@libero.it> :
[...]
>     after your e-mail, I redo the test with kernel 2.6.4-vanilla unchanged and
> in console mode (without X) I have no problem. I don't understand because the
> problem some day ago raise in console and with X. In my test the problem raise
> always when I copy file in KDE to PC by smbclient. So I think the problem was X
> but with kernel 2.6.3 the problem don't raise. The system hang and the only
                      ^ -> 4 I guess ?

r8169 in 2.6.3 has a bug which is fixed in 2.6.4.

> option is hardware-reset, nothing ping not respond and led do not change nay more.
>    I do the thing you told me with kernel unchanged
>    dd if=/dev/hda  of=/dev/null bs=1024k.... go well
>    dd if=/myfile of=/newfile ok
>    transfer (console) ok

Ok. Let's assume this rules out the disk susbsystem.

>    Retry with X
>    transfer KO

With 2.6.4 or 2.6.3 (I am lost here) ?

>    I recompile kernel as you told me.
> > Processor type and features  --->
> > [...]
> >   x x[ ] Symmetric multi-processing support                               x x   
> >   x x[ ] Preemptible Kernel                                               x x   
> >   x x[*] Local APIC support on uniprocessors                              x x   
> > 
> > Enable as well:
> > 
> > Kernel hacking  --->
> > [...]
> >   x x            [*] Magic SysRq key                                      x x   
>   retray test with KDE and the problem don't raise.

> 
> When the problem raised I saw in the kernel-changelog change in module r8169 so
> I thoungh the problem was NIC-module, the only change from two configuration.
> Now I only raise the problem (without your change) with KDE... I don't
> understand if is NIC or X-KDE problem.
> Can you help me to find who hang my system?

1 - use at least 2.6.4 or (better for r8169) 2.6.5-rcX-mm-something
2 - if something corrupts the descriptor rings of the r8169, it can lock the
    computer really hard. You _should_ apply the patch I sent. If something
    wicked happens, it may spit messages (dmesg/syslog). It is really
    important for debugging that this patch is applied. I hope I made this
    point clear :o)
3 - if you can reproduce the bug with 2.6.5-rcX-mm + extra patch, nmi_watchdog
    being enabled (do not forget to pass the "nmi_watchdog=1" option to the
    command line and check that it works as suggested in the previous message),
    nmi_watchdog may break some lock. Please report if the magic sysrq has any
    effect on the locked machine. Verify that your syslog daemon does not
    buffer writes and that it catches the kernel messages.

If you have a serial cable, it can help.

> I attach dmeg and lspci

[...]
> 01:00.0 VGA compatible controller: nVidia Corporation NV17 [GeForce4 MX 440] (re
v a3)

Can you send 'lsmod' output once X is started (not necessarily with KDE) ?

--
Ueimor
