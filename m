From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Fri, 24 Oct 2014 22:57:58 +0100
Message-ID: <20141024215758.GA25640@casper.infradead.org>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
 <CALnjE+o+aSE0cGnS60p_4ff6mhddK8oB0e0xMi+L0p1aa-P9vA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59343 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbaJXV6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 17:58:00 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+o+aSE0cGnS60p_4ff6mhddK8oB0e0xMi+L0p1aa-P9vA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/14 at 10:47am, Pravin Shelar wrote:
> On Wed, Oct 22, 2014 at 8:29 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > The internal and netdev vport remain part of openvswitch.ko. Encap
> > vports including vxlan, gre, and geneve can be built as separate
> > modules and are loaded on demand. Modules can be unloaded after use.
> > Datapath ports keep a reference to the vport module during their
> > lifetime.
> >
> > Allows to remove the error prone maintenance of the global list
> > vport_ops_list.
> >
> How error prone is this interface, can you give example? Set of ovs
> vport type is been pretty stable, so am not sure if we need loadable
> module support for vports implementations.

I was refering to how many other kernel APIs have been designed, a
registration API allowing a vport to be implemented exclusively in the
scope of a single file tends to be cleaner than having to touch multiple
files and maintaining an init list.

It also allows for OVS to be built into vmlinuz while vports can
remain as modules even if vxlan itself is built as a module.

As for new vports, GUE and LIS are candidates, encrypted VXLAN might
look for support and there are several VXLAN extensions currently
proposed as IETF drafts which might require new vports.
