From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 1/1] xen/netback: correctly calculate
 required slots of skb.
Date: Thu, 11 Jul 2013 12:12:24 +0100
Message-ID: <1373541144.5453.165.camel@hastur.hellion.org.uk>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
	 <1373530274.5453.148.camel@hastur.hellion.org.uk>
	 <51DE6DFD.9080007@oracle.com>
	 <1373536078.5453.159.camel@hastur.hellion.org.uk>
	 <4A59CC63-9B57-49FA-A2FD-6903C86E110E@oracle.com>
	 <3038108B-5529-452A-A488-4E616F7C1B8E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"msw@amazon.com" <msw@amazon.com>
To: Annie <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53713 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755031Ab3GKLM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jul 2013 07:12:27 -0400
In-Reply-To: <3038108B-5529-452A-A488-4E616F7C1B8E@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> > 
> > 
> > > 
> > > > The code here only 
> > > > increase count for the first time. I thought to initialize the
> > > > count in 
> > > > xen_netbk_count_skb_slots with 1 to avoid this. But thinking of
> > > > the 
> > > > extreme case when the header size is zero(not sure whether this
> > > > case 
> > > > could be true), I increase the count here to keep safe in case
> > > > header 
> > > > size is zero.
> > > 
> > > netfront requires that the first slot always contains some data,
> > > gop_frag_copy will BUG if that's not the case.
> > > 
> 
> 
> In gop_frag_copy, we can not go into the while if the size is 0. Which
> BUG_ON do you mean here?

in gop_frag_copy:
		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
			/*
			 * Netfront requires there to be some data in the head
			 * buffer.
			 */
			BUG_ON(*head);

Ian
