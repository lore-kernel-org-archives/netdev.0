From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Thu, 24 Oct 2002 14:22:25 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210241129.g9OBTpp09266@Port.imtp.ilyichevsk.odessa.ua>
References: <200210231218.18733.roy@karlsbakk.net> <200210231309.g9ND9Bp03373@Port.imtp.ilyichevsk.odessa.ua> <200210231536.24269.roy@karlsbakk.net>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com
In-Reply-To: <200210231536.24269.roy@karlsbakk.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 23 October 2002 11:36, Roy Sigurd Karlsbakk wrote:
> > > 905182 total                                      0.4741
> > > 121426 csum_partial_copy_generic                474.3203
> >
> > Well, maybe take a look at this func and try to optimize it?
>
> I don't know assembly that good - sorry.

Well, I like it. Maybe I can look into it. Feel free
to bug me :-)

> > >  93633 default_idle                             1800.6346
> > >  74665 do_wp_page                               111.1086
> >
> > What's this?
>
> do_wp_page is Defined as a function in: mm/memory.c
>
> comments from the file:
> [snip]

Please delete memory.o, rerun make bzImage, capture gcc
command used for compiling memory.c, modify it:

gcc ... -o memory.o  ->  gcc ... -S -o memory.s ...

and examine assembler code. Maybe something will stick out
(or use objdump to disassemble memory.o, I recall nice
option to produce assembler output with C code intermixed
as comments!) (send disasmed listing to me offlist).

> > >  65857 ide_intr                                 184.9916
> >
> > You have 1 ide_intr per 2 csum_partial_copy_generic... hmmm...
> > how large is your readahead? I assume you'd like to fetch
> > more sectors from ide per interrupt. (I hope you do DMA ;)
>
> doing DMA - RAID-0 with 1MB chunk size on 4 disks.

You should aim at maxing out IDE performance.
Please find out how many sectors you read in one go.
Maybe:

# cat /proc/interrupts
# dd bs=1m count=1 if=/dev/hda of=/dev/null
# cat /proc/interrupts

and calculate how many IDE interrupts happened. (1mb = 2048 sectors)
--
vda
