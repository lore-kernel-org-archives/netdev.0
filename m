From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCHv1] xen-netfront: always keep the Rx
 ring full of requests
Date: Thu, 02 Oct 2014 14:46:41 +0100
Message-ID: <542D7361020000780003C014@mail.emea.novell.com>
References: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <xen-devel@lists.xenproject.org>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: "David Vrabel" <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emea.novell.com ([130.57.118.101]:43791 "EHLO
	mail.emea.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaJBNqo convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Thu, 2 Oct 2014 09:46:44 -0400
In-Reply-To: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 02.10.14 at 15:33, <david.vrabel@citrix.com> wrote:
> A full Rx ring only requires 1 MiB of memory.  This is not enough
> memory that it is useful to dynamically scale the number of Rx
> requests in the ring based on traffic rates.

The performance benefits are nice, but does the above statement
scale to hundreds of guests with perhaps multiple NICs and/or
queues?

Jan

> Keeping the ring full of Rx requests handles bursty traffic better
> than trying to converges on an optimal number of requests to keep
> filled.
> 
> On a 4 core host, an iperf -P 64 -t 60 run from dom0 to a 4 VCPU guest
> improved from 5.1 Gbit/s to 5.6 Gbit/s.  Gains with more bursty
> traffic are expected to be higher.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
