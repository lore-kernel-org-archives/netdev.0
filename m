From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: fix sctp_connectx abi for ia32
 emulation/compat mode
Date: Mon, 17 Feb 2014 07:17:13 -0500
Message-ID: <20140217121713.GB17382@hmsreliant.think-freely.org>
References: <1392635471-31528-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47834 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbaBQMRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 07:17:20 -0500
Content-Disposition: inline
In-Reply-To: <1392635471-31528-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 12:11:11PM +0100, Daniel Borkmann wrote:
> SCTP's sctp_connectx() abi breaks for 64bit kernels compiled with 32bit
> emulation (e.g. ia32 emulation or x86_x32). Due to internal usage of
> 'struct sctp_getaddrs_old' which includes a struct sockaddr pointer,
> sizeof(param) check will always fail in kernel as the structure in
> 64bit kernel space is 4bytes larger than for user binaries compiled
> in 32bit mode. Thus, applications making use of sctp_connectx() won't
> be able to run under such circumstances.
> 
> Introduce a compat interface in the kernel to deal with such
> situations by using a 'struct compat_sctp_getaddrs_old' structure
> where user data is copied into it, and then sucessively transformed
> into a 'struct sctp_getaddrs_old' structure with the help of
> compat_ptr(). That fixes sctp_connectx() abi without any changes
> needed in user space, and lets the SCTP test suite pass when compiled
> in 32bit and run on 64bit kernels.
> 
> Fixes: f9c67811ebc0 ("sctp: Fix regression introduced by new sctp_connectx api")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
