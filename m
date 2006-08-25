From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [IPV6] Q: corrupt checksums when transferring data
Date: Fri, 25 Aug 2006 11:50:54 -0700
Message-ID: <20060825115054.134398d0@dxpl.pdx.osdl.net>
References: <36D9DB17C6DE9E40B059440DB8D95F5281CB69@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19072 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964923AbWHYSvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 14:51:07 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5281CB69@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006 11:13:48 -0700
"Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:

> I'm enabling e1000 to offload IPv6 since the 2.6.18+ kernels support it.
> The kernel I'm testing is 2.6.18-rc4.  

Yes, something is wrong with the GSO code. I am bisecting this bug
	http://bugzilla.kernel.org/show_bug.cgi?id=7050


It looks like GSO is handing an IPV6 segment down to the sky2 driver
even though it asks for only NETIF_F_TSO.

