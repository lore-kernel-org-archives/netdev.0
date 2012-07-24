From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Tue, 24 Jul 2012 15:08:34 -0300
Message-ID: <20120724180834.GB18401@oc1711230544.ibm.com>
References: <500BD558.2060803@mellanox.com>
 <20120722.171553.2139258607165498367.davem@davemloft.net>
 <500D4F31.9020408@linux.vnet.ibm.com>
 <500D556F.4000409@mellanox.com>
 <500D93F5.4090305@linux.vnet.ibm.com>
 <500DB9CE.5080100@linux.vnet.ibm.com>
 <CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
 <500E9F2E.4010209@linux.vnet.ibm.com>
 <500ED6E4.60909@mellanox.com>
 <500EDCF7.3010500@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shlomo Pongartz <shlomop@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	brking@linux.vnet.ibm.com
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:36814 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933396Ab2GXSIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 14:08:43 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 24 Jul 2012 15:08:41 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 40D6D352004E
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 14:08:36 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6OI7ppu17891414
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 15:07:52 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6OG8Qhl004442
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 13:08:27 -0300
Content-Disposition: inline
In-Reply-To: <500EDCF7.3010500@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 24, 2012 at 02:35:51PM -0300, Kleber Sacilotto de Souza wrote:
> On 07/24/2012 02:09 PM, Shlomo Pongartz wrote:
> 
> > On 7/24/2012 4:12 PM, Kleber Sacilotto de Souza wrote:
> >> On 07/23/2012 06:26 PM, Or Gerlitz wrote:
> >>
> >>> Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com> wrote:
> >>>>> For powerpc we have an IBM internal user space tool that injects the
> >>>>> error on the bus with the aid of the system firmware. The kernel used
> >>>>> was built with the option:
> >>>>> CONFIG_EEH=y
> >>>>> and without the AER options. I will run some more tests with the AER
> >>>>> options activated.
> >>>> I tested the powerpc error injection with
> >>>>
> >>>> CONFIG_EEH=y
> >>>> CONFIG_PCIEAER=y
> >>>> CONFIG_PCIEAER_INJECT=m
> >>>>
> >>>> and with the aer_inject module loaded and it didn't affect the EEH
> >>>> recovery, the adapter recovered as expected.
> >>> I wasn't sure to follow what did you mean by "it didn't affect the EEH
> >>> recovery", how did you use the aer_inject module, is that through
> >>> user-space tool which is available for us?
> >>
> >> I wanted to say that I was testing before only with the EEH option
> >> activated, then I activated the AER options on my powerpc system just to
> >> make sure these options when activate wouldn't affect the EEH recovery.
> >> I haven't injected and AER error since I don't have a system with
> >> hardware support for it.
> >>
> >>
> >> Thanks,
> > 
> > Hi
> > 
> > Using a special extender card I've powered down the card.
> > None of the callbacks were called (I added printks to be sure).
> > Shouldn't one on the callbacks be called?
> > 
> > Shlomo Pongratz.
> > 
> 
> 
> What does this extender card do exactly? If it does hot plugging, it
> will call the remove and probe callbacks.
> 
> 
> -- 
> Kleber Sacilotto de Souza
> IBM Linux Technology Center

I assume it just powers down the card, ie, it will not respond anymore
to any bus messages, which may cause an error report.

Shlomo, is it the system you are using AER-capable? From what I see from
code and documentation, you must have root ports which support AER. Is
that the case?

Regards.
Cascardo.
