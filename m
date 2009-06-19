From: Peter Chacko <peterchacko35@gmail.com>
Subject: Re: can we reuse an skb
Date: Fri, 19 Jun 2009 12:51:59 +0530
Message-ID: <1f808b4a0906190021s19a710b9k8dca22f160eb8dfb@mail.gmail.com>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
	 <60230E21F17E384C9BF0B9C98D9E3FDC048963D6@sgp-sg-mb02.sgp.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: jon_zhou@agilent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:64059 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975AbZFSHV4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 03:21:56 -0400
Received: by pxi27 with SMTP id 27so1608639pxi.33
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 00:21:59 -0700 (PDT)
In-Reply-To: <60230E21F17E384C9BF0B9C98D9E3FDC048963D6@sgp-sg-mb02.sgp.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radha,

skb memory is coming from slab allocation pool, which itself are
re-usable pools. kmalloc(ATOMIC) on these object caches don't incur
much penalty as think for a case when it does memory
allocation/de-allocation. So the intelligence you want to put in the
driver is already done by slab layer. But if you want to add some
thing like per-flow ring-buffers, optimized for a point-to-point link
or similar purpose, you can have a driver level cache .

thanks

On Fri, Jun 19, 2009 at 12:21 PM, <jon_zhou@agilent.com> wrote:
> I am also thinking about this...
>
> i.e.pcnet32.c
> seems the skb will be claimed to be unuseful(mark some bits) in the d=
evice driver, than it will be recycled in the softirq handler,
>
> that means unable to reuse it, unless modidy the driver.
>
> Regards,
> zhou rui
>
> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of Radha Mohan
> Sent: Friday, June 19, 2009 2:47 PM
> To: netdev@vger.kernel.org
> Subject: can we reuse an skb
>
>
> Hi,
>
> For an ethernet driver, we need to allocate some pool of SKBs for rec=
eiving packets. Is there any way we can reuse the same SKBs without the=
 need to re-allocate in atomic every time one has been used up for neti=
f_rx().
>
> Any pointers will be helpful.
>
> -- Mohan
>
>
> =A0 =A0 =A0ICC World Twenty20 England &#39;09 exclusively on YAHOO! C=
RICKET http://cricket.yahoo.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in =
the body of a message to majordomo@vger.kernel.org More majordomo info =
at =A0http://vger.kernel.org/majordomo-info.html
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
