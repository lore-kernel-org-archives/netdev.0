From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [Bugme-new] [Bug 12087] New: [drivers/net/cxgb3/sge.c:563]: Possible
 memory leak: s
Date: Mon, 24 Nov 2008 09:04:41 -0800
Message-ID: <492ADEA9.60502@chelsio.com>
References: <bug-12087-10286@http.bugzilla.kernel.org/><20081122213532.fe01a22c.akpm@linux-foundation.org> <20081123054019.532d83ac@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, danielm77@spray.se
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:23651 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbYKXREo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 12:04:44 -0500
In-Reply-To: <20081123054019.532d83ac@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> [adding cxgb3 maintainer to cc list]

Thanks, I'll look at this.

Divy

> 
> On Sat, 22 Nov 2008 21:35:32 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via
>> the bugzilla web interface).
>>
>> On Sat, 22 Nov 2008 21:11:51 -0800 (PST)
>> bugme-daemon@bugzilla.kernel.org wrote:
>>
>> > http://bugzilla.kernel.org/show_bug.cgi?id=12087
>> >
>> >            Summary: [drivers/net/cxgb3/sge.c:563]: Possible memory
>> > leak: s Product: Drivers
>> >            Version: 2.5
>> >      KernelVersion: latest git tree
>> >           Platform: All
>> >         OS/Version: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: normal
>> >           Priority: P1
>> >          Component: Network
>> >         AssignedTo: jgarzik@pobox.com
>> >         ReportedBy: danielm77@spray.se
>> >
>> >
>> > There will be a memory leak in the function alloc_ring when the
>> > parameter sw_size is nonzero and metadata is NULL. I don't know if
>> > that can happen.
>> >
>> > Here is the code, taken from the latest git tree.
>> >
>> > static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t
>> > elem_size, size_t sw_size, dma_addr_t * phys, void *metadata)
>> > {
>> >         size_t len = nelem * elem_size;
>> >         void *s = NULL;
>> >         void *p = dma_alloc_coherent(&pdev->dev, len, phys,
>> > GFP_KERNEL);
>> >
>> >         if (!p)
>> >                 return NULL;
>> >         if (sw_size) {
>> >                 s = kcalloc(nelem, sw_size, GFP_KERNEL);
>> >
>> >                 if (!s) {
>> >                         dma_free_coherent(&pdev->dev, len, p,
>> > *phys); return NULL;
>> >                 }
>> >         }
>> >         if (metadata)
>> >                 *(void **)metadata = s;
>> >         memset(p, 0, len);
>> >         return p;
>> > }
>> >
>> >
>>
>> yeah, that is a bit silly-looking.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

