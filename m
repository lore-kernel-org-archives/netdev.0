From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Tue, 30 Mar 2004 01:16:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403300116.41377.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040330002047.D4744@electric-eye.fr.zoreil.com> <200403300050.42367.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fjortis.info>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <200403300050.42367.vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 30 March 2004 00:50, Denis Vlasenko wrote:
> I think bug can be considered fixed if I can start
> netcat UDP flood, wait however long I want, then press
> ctrl-C and get my bash prompt back. Local netcat
> closes socket and exits, remote netcat gets its
> icmp 'port unreachable' and exits too. Everybody's
> happy.
>
> Oopses are gone but it looks like box is so much interrupt
> flooded that userspace has no chance of processing ctrl-C.
> What can we do? I think driver can do something useful
> whet it detects 'too much work in interrupt'. Disabling rx
> for several ms seems like 'quick and dirty' way.

I just verified that even if I stop remote netcat,
box does not recover. Console fills with
"Too much work at interrupt, status=0x0020"
0x0020 is RBU = 0x00000020, /* receive buffer unavailable */

> Francois what do you think? Can you code something up
> for me to test?
>
> On Tuesday 30 March 2004 00:20, Francois Romieu wrote:
> > Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>:
> > [...]
> >
> > > in intr_handler():
> > >                 if (--boguscnt < 0) {
> > >                         printk(KERN_WARNING "%s: Too much work at
> > > interrupt, " "status=0x%4.4x.\n", dev->name, intr_status); break;
> > >                 }
> > > Shall we do something with this condition?
> > > What if card is simply go mad? Maybe card reset?
> >
> > 1 - Yes.
> > 2 - disable the offending interruption/NAPI (reset is not needed)
>
> Imagine that hardware got stuck with intr constantly asserted.
> Reset can cure that. In any event, it might give us a needed
> pause of several ms, just what I want.
>
> If you worry about lost packets, that's not a concern -
> if we reached this, we are dropping tons of them already.
--
vda
