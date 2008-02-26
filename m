From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
Date: Tue, 26 Feb 2008 16:47:34 +0100
Message-ID: <E1JU21m-0001wp-ET@pomaz-ex.szeredi.hu>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>  <E1JU1kk-0001t9-25@pomaz-ex.szeredi.hu> <1204040629.6242.326.camel@lappy>
Cc: miklos@szeredi.hu, neilb@suse.de, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org,
	trond.myklebust@fys.uio.no
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:46274 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595AbYBZPrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 10:47:48 -0500
In-reply-to: <1204040629.6242.326.camel@lappy> (message from Peter Zijlstra on
	Tue, 26 Feb 2008 16:43:49 +0100)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > > mm-page_file_methods.patch
> > > > 
> > > >     This makes page_offset and others more expensive by adding a
> > > >     conditional jump to a function call that is not usually made.
> > > > 
> > > >     Why do swap pages have a different index to everyone else?
> > > 
> > > Because the page->index of an anonymous page is related to its (anon)vma
> > > so that it satisfies the constraints for vm_normal_page().
> > > 
> > > The index in the swap file it totally unrelated and quite random. Hence
> > > the swap-cache uses page->private to store it in.
> > 
> > Yeah, and putting the condition into page_offset() will confuse code
> > which uses it for finding the offset in the VMA or in a tmpfs file.
> > 
> > So why not just have a separate page_swap_offset() function, used
> > exclusively by swap_in/out()?
> 
> Ah, we can do the page_file_offset() to match page_file_index() and
> page_file_mapping(). And convert NFS to use page_file_offset() where
> appropriate, as I already did for these others.
> 
> That would sort out the mess, right?

Yes, that sounds perfect.

Miklos
