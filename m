From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 16:01:49 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210231309.g9ND9Bp03373@Port.imtp.ilyichevsk.odessa.ua>
References: <200210231218.18733.roy@karlsbakk.net> <200210231306.18422.roy@karlsbakk.net>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com
In-Reply-To: <200210231306.18422.roy@karlsbakk.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 23 October 2002 09:06, Roy Sigurd Karlsbakk wrote:
> > I've got this video server serving video for VoD. problem is the P4
> > 1.8 seems to be maxed out by a few system calls. The below output
> > is for ~50 clients streaming at ~4.5Mbps. if trying to increase
> > this to ~70, the CPU maxes out.
> >
> > Does anyone have an idea?
>
> ...adding the whole profile output - sorted by the first column this
> time...
>
> 905182 total                                      0.4741
> 121426 csum_partial_copy_generic                474.3203

Well, maybe take a look at this func and try to optimize it?

>  93633 default_idle                             1800.6346
>  74665 do_wp_page                               111.1086

What's this?

>  65857 ide_intr                                 184.9916

You have 1 ide_intr per 2 csum_partial_copy_generic... hmmm...
how large is your readahead? I assume you'd like to fetch
more sectors from ide per interrupt. (I hope you do DMA ;)

>  53636 handle_IRQ_event                         432.5484
>  21973 do_softirq                               107.7108
>  20498 e1000_intr                               244.0238

I know zero about networking, but why 120 000 csum_partial_copy_generic
and inly 20 000 nic interrupts? That may be abnormal.
--
vda
