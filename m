From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: add support for
 IPv6 offloads
Date: Wed, 15 Jan 2014 16:03:31 +0000
Message-ID: <52D6BF630200007800113EFB@nat28.tlf.novell.com>
References: <1389799111-8372-1-git-send-email-paul.durrant@citrix.com>
 <52D6A868.6040707@citrix.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD0208071@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Andrew Cooper" <Andrew.Cooper3@citrix.com>,
	"Paul Durrant" <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:36113 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaAOQDd convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Wed, 15 Jan 2014 11:03:33 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0208071@AMSPEX01CL01.citrite.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 15.01.14 at 16:54, Paul Durrant <Paul.Durrant@citrix.com> wrote:
>> From: Andrew Cooper [mailto:andrew.cooper3@citrix.com]
>> On 15/01/14 15:18, Paul Durrant wrote:
>> > +	err = xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv6", "%d", 1);
>> 
>> "%d", 1 results in a constant string.  xenbus_write() would avoid a
>> transitory memory allocation.
> 
> This code is consistent with all the other xenbus_printf()s in the 
> neighbourhood and does it really matter?

I think we should always strive to have the simplest possible code
that fulfills the purpose. And hence we shouldn't be setting further
bad precedents. (In fact I have a patch queued to replace all the
unnecessary xenbus_printf()s with xenbus_write()s on
linux-2.6.18-xen.hg, and may look into porting this to the
respective upstream components.)

Jan
