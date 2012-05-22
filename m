From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [Bug 43277] New: net/e1000e set mtu larger than 1500 fails
Date: Tue, 22 May 2012 18:28:12 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A184188DB12A@ORSMSX102.amr.corp.intel.com>
References: <20120522111950.4548747c@nehalam.linuxnetplumber.net>
 <20120522112518.70294c0e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"che@chrekh.se" <che@chrekh.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:58954 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759947Ab2EVS2O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 14:28:14 -0400
In-Reply-To: <20120522112518.70294c0e@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> Sent: Tuesday, May 22, 2012 11:25 AM
> To: che@chrekh.se
> Cc: netdev@vger.kernel.org; e1000-devel@lists.sf.net
> Subject: Re: [Bug 43277] New: net/e1000e set mtu larger than 1500
> fails
> 
> On Tue, 22 May 2012 11:19:50 -0700
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> >
> >
> > Begin forwarded message:
> >
> > Date: Tue, 22 May 2012 18:13:21 +0000 (UTC)
> > From: bugzilla-daemon@bugzilla.kernel.org
> > To: shemminger@linux-foundation.org
> > Subject: [Bug 43277] New: net/e1000e set mtu larger than 1500 fails
> >
> >
> > https://bugzilla.kernel.org/show_bug.cgi?id=43277
> >
> >            Summary: net/e1000e set mtu larger than 1500 fails
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 3.4
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: che@chrekh.se
> >         Regression: Yes
> >
> >
> > In kernel 3.4 I can no longer use jumbo-frames with my e1000e
> network
> > interface.
> >
> >  $ sudo ip link set eth1 mtu 9000
> >  RTNETLINK answers: Invalid argument
> 
> I believe the problem is detected here. Check system console log
> (dmesg).
> The hardware does not allow receive hashing and checksum offload
> together
> in Jumbo mode.
> 
> 	/*
> 	 * IP payload checksum (enabled with jumbos/packet-split when
> 	 * Rx checksum is enabled) and generation of RSS hash is
> 	 * mutually exclusive in the hardware.
> 	 */
> 	if ((netdev->features & NETIF_F_RXCSUM) &&
> 	    (netdev->features & NETIF_F_RXHASH)) {
> 		e_err("Jumbo frames cannot be enabled when both receive
> checksum offload and receive hashing are enabled.  Disable one of the
> receive offload features before enabling jumbos.\n");
> 		return -EINVAL;
> 	}

That is correct.
