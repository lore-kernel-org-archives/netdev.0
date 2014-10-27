From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Mon, 27 Oct 2014 21:47:22 +0000
Message-ID: <20141027214722.GA2783@casper.infradead.org>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
 <CALnjE+o+aSE0cGnS60p_4ff6mhddK8oB0e0xMi+L0p1aa-P9vA@mail.gmail.com>
 <20141024215758.GA25640@casper.infradead.org>
 <CALnjE+opCLA9KJ5RHaUs1vbx41p6=iUi9B59Q7G0TeSTmWm7_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53001 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbaJ0VrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 17:47:23 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+opCLA9KJ5RHaUs1vbx41p6=iUi9B59Q7G0TeSTmWm7_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/14 at 10:14am, Pravin Shelar wrote:
> On Fri, Oct 24, 2014 at 2:57 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > I was refering to how many other kernel APIs have been designed, a
> > registration API allowing a vport to be implemented exclusively in the
> > scope of a single file tends to be cleaner than having to touch multiple
> > files and maintaining an init list.
> >
> This has never been issue in openvswitch. Plus we do not need loadable
> vport module to fix this issue.
> 
> > It also allows for OVS to be built into vmlinuz while vports can
> > remain as modules even if vxlan itself is built as a module.
> >
> 
> What is problem with current OVS built into kernel?

What I mean specifically is the following dependency logic which will
no longer be required:

depends on NET_IPGRE_DEMUX && !(OPENVSWITCH=y && NET_IPGRE_DEMUX=m)

The patch also brings additional flexibility to users of
distributions. Distros typically ship something like an allmodconfig
so a user can either run openvswitch.ko with all encaps compiled in
or not run openvswitch.ko. With vports as module, a user can blacklist
a certain encap type.

Another advantage is obviously that users can run additional vport
types on top of their distribution kernels.

Is there anything specific that you are concerned with in regard
to this proposed change?
