From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Tue, 28 Oct 2014 08:10:12 +0000
Message-ID: <20141028081012.GB2783@casper.infradead.org>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
 <CALnjE+o+aSE0cGnS60p_4ff6mhddK8oB0e0xMi+L0p1aa-P9vA@mail.gmail.com>
 <20141024215758.GA25640@casper.infradead.org>
 <CALnjE+opCLA9KJ5RHaUs1vbx41p6=iUi9B59Q7G0TeSTmWm7_w@mail.gmail.com>
 <20141027214722.GA2783@casper.infradead.org>
 <CALnjE+p5b5EzLkY6_6J7jvwyf9rUdu-JGbdf5r3bDuhgndoeeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56525 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbaJ1IKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 04:10:14 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+p5b5EzLkY6_6J7jvwyf9rUdu-JGbdf5r3bDuhgndoeeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/14 at 05:27pm, Pravin Shelar wrote:
> On Mon, Oct 27, 2014 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > What I mean specifically is the following dependency logic which will
> > no longer be required:
> >
> > depends on NET_IPGRE_DEMUX && !(OPENVSWITCH=y && NET_IPGRE_DEMUX=m)
> >
> > The patch also brings additional flexibility to users of
> > distributions. Distros typically ship something like an allmodconfig
> > so a user can either run openvswitch.ko with all encaps compiled in
> > or not run openvswitch.ko. With vports as module, a user can blacklist
> > a certain encap type.
> >
> > Another advantage is obviously that users can run additional vport
> > types on top of their distribution kernels.
> >
> > Is there anything specific that you are concerned with in regard
> > to this proposed change?
> 
> OVS vport code is not alot and making it plugable module does not save
> much space. Even with this patch user can not load any vport type
> since we still need to define the type in kernel interface and add the
> support in userspace netdev layer. Therefore this patch adds
> complexity without much gain.

Defining the type in the header now only serves the purpose of
reserving unique vport types. It will be perfectly fine to compile a
vport module of a newer OVS user space against an older kernel (that
has the vport API) and load the vport module even though that kernel
version does not have any explicit awareness of that type. This is
something users of distribution kernel like to do because they
typically can't recompile the kernel without break support contracts.
