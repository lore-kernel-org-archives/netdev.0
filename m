From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/2] net: introduce IFF_NO_QUEUE as successor of zero
 tx_queue_len
Date: Thu, 13 Aug 2015 12:11:57 -0700
Message-ID: <20150813121157.5166efb1@urahara>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
	<20150813104950.1b8346f2@urahara>
	<20150813204037.3c4e68a4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, fw@strlen.de,
	cwang@twopensource.com, eric.dumazet@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33750 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbbHMTLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 15:11:47 -0400
Received: by pabyb7 with SMTP id yb7so42959407pab.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 12:11:46 -0700 (PDT)
In-Reply-To: <20150813204037.3c4e68a4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Aug 2015 20:40:37 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Thu, 13 Aug 2015 10:49:50 -0700
> Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
> > On Thu, 13 Aug 2015 19:01:05 +0200
> > Phil Sutter <phil@nwl.cc> wrote:
> > 
> > > Up to now, drivers being aware of the above applying to them set
> > > dev->tx_queue_len to zero to indicate no qdisc should be attached to the
> > > interface they drive and the kernel reacts upon this by assigning the noop
> > > qdisc instead of the default pfifo_fast. This implicit agreement though leads
> > > to an inconvenient situation once a user tries to attach a real qdisc to these
> > > devices, as the formerly special tx_queue_len value becomes a regular one,
> > 
> > So this is a workaround for user ignorance by introducing kernel API complexity.
> > Before user sets qdisc, why don't they set tx queue length?
> 
> Please don't insist on keeping this broke interface... how should users
> know that BEFORE adding a qdisc they MUST change the _device_ tx queue
> length (not zero).

Before setting any qdisc, they should set queue length anyway.

>  Getting "back" to the original state, they MUST
> change the device tx queue len back to zero BEFORE deleting the qdisc,
> such that when assigning the default queue qdisc the system detects
> this device can work without a qdisc.  Changing the tx queue len to
> zero after the qdisc is deleted will have not effect. 
> 
> Listen to the description, that interface is broken. The kernel really
> needs to hide these details from userspace.
> 
> It even allows you to misconfigure the kernel, by tricking the kernel
> into assigning noqueue to physical devices that really need it.

But adding a flag risks breaking external scripts.
