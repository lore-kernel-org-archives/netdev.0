From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH] SIW: iWARP Protocol headers
Date: Wed, 6 Oct 2010 18:02:39 +0200
Message-ID: <AANLkTikGqsnXJpnifdKEZr6PoJafZ1N+5zNNaUVMeuQu@mail.gmail.com>
References: <AANLkTimkJHntzqL5fs+6kTTq-3kzwmoDtWyVq=qGe6vj@mail.gmail.com> <OFC70D3F8A.C5D69C2F-ONC12577B4.0044CFB7-C12577B4.0046C012@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	netdev@vger.kernel.org
To: Bernard Metzler <BMT@zurich.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49294 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114Ab0JFQDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 12:03:02 -0400
In-Reply-To: <OFC70D3F8A.C5D69C2F-ONC12577B4.0044CFB7-C12577B4.0046C012@ch.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 6, 2010 at 2:52 PM, Bernard Metzler <BMT@zurich.ibm.com> wrote:
>
>
> linux-rdma-owner@vger.kernel.org wrote on 10/05/2010 06:10:45 PM:
>
> > On Tue, Oct 5, 2010 at 8:53 AM, Bernard Metzler <bmt@zurich.ibm.com>
> wrote:
> > > +} __attribute__((__packed__));
> >
> > Apparently you make extensive use of the packed attribute. Please read
> > this blog entry, in which it is explained why this is harmful:
> >
> > http://digitalvampire.org/blog/index.php/2006/07/31/why-you-
> > shouldnt-use-__attribute__packed/
> >
> right, thanks, i was not aware of that
> big overhead.
> but...there are reasons why we may need it _packed_:
> (1) to get the size of the packet hdr
> (2) to read/write the hdr content
>
> (1) is not harmful. (2) could be limited to
> just one read/write operation per rx/tx path
> and all other access could be done on a
> structure which contains the host representation
> of the hdr content. both structures could coexist
> in a union, part of the rx or tx context.
> would that satisfy your complain?

Please have a look at e.g. the header file <scsi/srp.h>. As you can
see in that header file, __attribute__((__packed__)) is only specified
when absolutely necessary.

Bart.
