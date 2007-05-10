From: "Qi, Yanling" <Yanling.Qi@lsi.com>
Subject: RE: SG_IO with >4k buffer size to iscsi sg device causes "Bad page" panic
Date: Thu, 10 May 2007 12:31:18 -0600
Message-ID: <0F08E10B769EAF4EA2C43A573B8CC87FB572B9@NAMAIL3.ad.lsil.com>
References: <E1HlvkD-0004zY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<linux-iscsi-devel@lists.sourceforge.net>, <michaelc@cs.wisc.edu>,
	<dougg@torque.net>, <James.Bottomley@steeleye.com>
To: <open-iscsi@googlegroups.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <E1HlvkD-0004zY-00@gondolin.me.apana.org.au>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: open-iscsi@googlegroups.com [mailto:open-iscsi@googlegroups.com]
On
> Behalf Of Herbert Xu
> Sent: Wednesday, May 09, 2007 6:39 PM
> To: Qi, Yanling
> Cc: netdev@vger.kernel.org; linux-scsi@vger.kernel.org; open-
> iscsi@googlegroups.com; linux-iscsi-devel@lists.sourceforge.net; Qi,
> Yanling; michaelc@cs.wisc.edu; dougg@torque.net;
> James.Bottomley@steeleye.com
> Subject: Re: SG_IO with >4k buffer size to iscsi sg device causes "Bad
> page" panic
> 
> 
> Qi, Yanling <Yanling.Qi@lsi.com> wrote:
> > @@ -2571,6 +2572,13 @@ sg_page_malloc(int rqSz, int lowDma, int
> >                resp = (char *) __get_free_pages(page_mask, order);
> > /* try half */
> >                resSz = a_size;
> >        }
> > +       tmppage = virt_to_page(resp);
> > +       for( m = PAGE_SIZE; m < resSz; m += PAGE_SIZE )
> > +       {
> > +               tmppage++;
> > +               SetPageReserved(tmppage);
> > +       }
> > +
> 
[Qi, Yanling]
If I do a get_page() at sg_page_malloc() time and then do a put_page()
at sg_page_free() time, I worry about a race condition that the page
gets re-used before calling free_pages().

Thanks,
Yanling
