From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: Unable to create more than 1 guest virtio-net device using
 vhost-net backend
Date: Mon, 22 Mar 2010 16:41:14 -0700
Message-ID: <1269301274.18093.40.camel@w-sridhar.beaverton.ibm.com>
References: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com>
	 <20100321095544.GA6443@redhat.com> <4BA5F0D5.6020801@redhat.com>
	 <20100321101527.GH6443@redhat.com> <4BA5F50B.8080302@redhat.com>
	 <20100321113443.GB12339@redhat.com> <4BA609E5.40504@redhat.com>
	 <20100322181623.GA20188@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, gleb@redhat.com,
	David Stevens <dlstevens@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:63563 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab0CVXlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 19:41:19 -0400
In-Reply-To: <20100322181623.GA20188@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-22 at 20:16 +0200, Michael S. Tsirkin wrote:
> On Sun, Mar 21, 2010 at 01:58:29PM +0200, Avi Kivity wrote:
> > On 03/21/2010 01:34 PM, Michael S. Tsirkin wrote:
> >> On Sun, Mar 21, 2010 at 12:29:31PM +0200, Avi Kivity wrote:
> >>    
> >>> On 03/21/2010 12:15 PM, Michael S. Tsirkin wrote:
> >>>      
> >>>>>> Nothing easy that I can see. Each device needs 2 of these.  Avi, Gleb,
> >>>>>> any objections to increasing the limit to say 16?  That would give us
> >>>>>> 5 more devices to the limit of 6 per guest.
> >>>>>>
> >>>>>>
> >>>>>>            
> >>>>> Increase it to 200, then.
> >>>>>
> >>>>>          
> >>>> OK. I think we'll also need a smarter allocator
> >>>> than bus->dev_count++ than we now have. Right?
> >>>>
> >>>>        
> >>> No, why?
> >>>      
> >> We'll run into problems if devices are created/removed in random order,
> >> won't we?
> >>    
> >
> > unregister_dev() takes care of it.
> >
> >>> Eventually we'll want faster scanning than the linear search we employ
> >>> now, though.
> >>>      
> >> Yes I suspect with 200 entries we will :). Let's just make it 16 for
> >> now?
> >>    
> >
> > Let's make it 200 and fix the performance problems later.  Making it 16  
> > is just asking for trouble.
> 
> I did this and performance with vhost seems to become much more noisy,
> and drop by about 10% on average, even though in practice only
> a single device is created. Still trying to figure it out ...
> Any idea?

I am not sure if this 10% variation is due to the increase of NR_IO_BUS_DEVS.
In our testing, we do see variations of 10% or higher between multiple netperf 
instances with the same setup/configuration when using virtio/vhost.

Thanks
Sridhar

