From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [IPV6] Q: corrupt checksums when transferring data
Date: Fri, 25 Aug 2006 13:25:25 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5281CD11@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42142 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S932408AbWHYUZ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 16:25:27 -0400
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 25 Aug 2006 11:13:48 -0700
> "Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:
> 
>> I'm enabling e1000 to offload IPv6 since the 2.6.18+ kernels support
>> it. The kernel I'm testing is 2.6.18-rc4.
> 
> Yes, something is wrong with the GSO code. I am bisecting this bug
> 	http://bugzilla.kernel.org/show_bug.cgi?id=7050
> 
> 
> It looks like GSO is handing an IPV6 segment down to the sky2 driver
> even though it asks for only NETIF_F_TSO.

Ah ha, I was wondering if that bug report on sky2 might be related to
this issue.  E1000 actually sends the data I think (it just has a bad
checksum) when handed a too long frame.  Seems like the stack should
never give us something longer than the MTU + enet header, esp with all
hardware offloads disabled.

So I have a very easy repro with netperf
on remote: netserver -4 -6
netperf -H lh2-6,6 -t TCP_MAERTS -- -m4K -S128K -s128K

The remote will generate the bad frames.

Jesse
