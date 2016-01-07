From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: WARN trace - skb_warn_bad_offload - vxlan - large udp packet -
 udp checksum disabled
Date: Wed, 6 Jan 2016 18:23:54 -0800
Message-ID: <20160106182354.000044e9@unknown>
References: <FC41C24E35F18A40888AACA1A36F3E418AFD00B5@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@nicira.com>,
	"Jiri Benc" <jbenc@redhat.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, jesse.brandeburg@intel.com
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19511 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291AbcAGCX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 21:23:58 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFD00B5@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Dec 2015 01:35:27 +0000
"Nelson, Shannon" <shannon.nelson@intel.com> wrote:

> Using a slightly modified version of udpspam (see diff below - hopefully
> not mangled by corporate email servers), where I set the SO_NO_CHECK
> socket option and can specify a large buffer size, I can reliably get
> the following WARN trace.  I have reproduced this on both ixgbe and
> i40e drivers using "udpspam-no-check <target-ip> 6000".
> 
> It looks to me like this is in the Tx path before we get to the actual
> NIC drivers, but I may be wrong.
> 
> 
> [ 1757.644324] ------------[ cut here ]------------
> [ 1757.644333] WARNING: CPU: 22 PID: 5537 at net/core/dev.c:2423 skb_warn_bad_offload+0x104/0x111()

Was anyone able to take a look at this?  There is a pretty clear
reproducer in the original mail.

I know SO_NO_CHECK is a lightly used option, but it does exist and we
found a userspace program that tries to use it.
