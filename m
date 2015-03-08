From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vlan: allow changing VLAN id and protocol
Date: Sun, 8 Mar 2015 14:44:32 -0700
Message-ID: <20150308144432.02f9c311@urahara>
References: <20150308110624.5ab6f662@urahara>
	<54FC9426.7040708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Kirsher <tarbal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:42541 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbbCHVog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 17:44:36 -0400
Received: by padfa1 with SMTP id fa1so67460919pad.9
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 14:44:35 -0700 (PDT)
In-Reply-To: <54FC9426.7040708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 08 Mar 2015 11:25:42 -0700
Jeff Kirsher <tarbal@gmail.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA512
> 
> On 03/08/2015 11:06 AM, Stephen Hemminger wrote:
> > 
> > The VLAN netlink interface allows changing the ID and protocol of an existing
> > VLAN, but it was being ignored. Move the initialization of the proto and
> > id into the change function to fix that.
> > 
> > Example of the problem:
> >   # modprobe dummy
> >   # ip li set dev dummy0 up
> >   # ip li add link dummy0 name dummy0.10 type vlan id 100
> >   # ip li set dummy0.10 type vlan id 111
> >   # ip -d li show dev dummy0.10
> > 19: dummy0.10@dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT 
> >     link/ether be:d3:7c:7f:86:18 brd ff:ff:ff:ff:ff:ff
> >     vlan id 100 <REORDER_HDR> 
> >             ^^^ should be 111
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Self-NAK

This needs more state work to handle the case of GARP and all the
filtering stuff.  There be small dragons here.
