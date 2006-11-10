From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Questions regarding network drivers
Date: Fri, 10 Nov 2006 09:55:21 -0800
Message-ID: <20061110095521.058b2014@freekitty>
References: <20061110100004.GA18739@2ka.mipt.ru>
	<661353.35559.qm@web31513.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24230 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161911AbWKJRzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 12:55:32 -0500
To: Jonathan Day <imipak@yahoo.com>
In-Reply-To: <661353.35559.qm@web31513.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Nov 2006 09:34:33 -0800 (PST)
Jonathan Day <imipak@yahoo.com> wrote:

> 
> --- Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > On Thu, Nov 09, 2006 at 07:06:00PM -0800, Jonathan
> > Day (imipak@yahoo.com) wrote:
> > > Hi,
> > > 
> > > I've got an interesting problem to contend with
> > and
> > > need some advice from the great wise ones here.
> > > 
> > > First of all, is it possible (and/or "reasonable
> > > practice") when developing a network driver to do
> > > zero-copy transfers between main memory and the
> > > network device?
> > 
> > What do you mean?
> > DMA from NIC memory into CPU memory?
> 
> Yes. I want to bypass the kernel altogether and think
> there may be a way to do this, but want to make very
> certain that I'm not going down the wrong track.
> 

This is not normally possible because network data could be intended
for multiple sockets. It is not possible to know where to DMA the
data to until you have done all the necessary protocol demultiplexing
and filtering. There has been talk of having really smart hardware
to help.

> The underlying problem is this. The group I'm working
> with is messing about with building their own
> networking device that will run at an equal speed to
> the bus leading to the host (2.5 gigabits/second). The
> device has its own DMA controller and can operate as
> bus master.
> 
> It's my task to figure out how to get the data into
> the host at near-100% bandwidth without dropping
> anything, with minimal latency and real-time
> characteristics.

You might want to look at RDMA Infiniband model.
