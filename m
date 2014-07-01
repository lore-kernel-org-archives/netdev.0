From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [systemd-devel] [PATCH] Use dev_port for the ID of a network
 device.
Date: Tue, 1 Jul 2014 09:32:08 -0300
Message-ID: <20140701123208.GC1204@oc0268524204.ibm.com>
References: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <CAPXgP13o=qZc0q+Af0sd6bLKUawKYw0L_SLqh3VgLZBJ1CfYSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kay Sievers <kay@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:50254 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbaGAMcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 08:32:17 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 1 Jul 2014 09:32:14 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 835ED1DC006A
	for <netdev@vger.kernel.org>; Tue,  1 Jul 2014 08:32:11 -0400 (EDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s61CVRDx61538478
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 09:31:27 -0300
Received: from d24av02.br.ibm.com (localhost [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s61CWATp004345
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 09:32:11 -0300
Content-Disposition: inline
In-Reply-To: <CAPXgP13o=qZc0q+Af0sd6bLKUawKYw0L_SLqh3VgLZBJ1CfYSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2014 at 02:33:19AM +0200, Kay Sievers wrote:
> On Mon, Jun 30, 2014 at 10:36 PM, Thadeu Lima de Souza Cascardo
> <cascardo@linux.vnet.ibm.com> wrote:
> > For network devices on the same PCI function, dev_id should not be used,
> > since its purpose is for IPv6 support on interfaces with the same MAC
> > address.
> >
> > The new dev_port sysfs attribute should be used when it is found. When
> > it is not, using dev_id might work.
> 
> I don't see a problem switching this over, but why would we keep using
> dev_id if it is not the right thing to use?
> 
> Kay
> 

Because dev_port has only been introduced into Linux 3.15, and some
drivers used dev_id before Linux 3.10. It's not an ideal situation, so I
think it's important to keep some compatibility for the time being. Or
we could simply drop dev_id, and force everyone to do the right thing
and backport dev_port support and fix their drivers.

Cascardo.
