From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCHv1 net] xen-netback: support frontends without
 feature-rx-notify again
Date: Mon, 5 Jan 2015 11:51:43 +0000
Message-ID: <1420458703.22423.30.camel@citrix.com>
References: <1418901186-14478-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	James Harper <james@ejbdigital.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:14014 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218AbbAELwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 06:52:01 -0500
In-Reply-To: <1418901186-14478-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-12-18 at 11:13 +0000, David Vrabel wrote:
> Commit bc96f648df1bbc2729abbb84513cf4f64273a1f1 (xen-netback: make
> feature-rx-notify mandatory) incorrectly assumed that there were no
> frontends in use that did not support this feature.  But the frontend
> driver in MiniOS does not and since this is used by (qemu) stubdoms,
> these stopped working.
> 
> Netback sort of works as-is in this mode except:
> 
> - If there are no Rx requests and the internal Rx queue fills, only
>   the drain timeout will wake the thread.  The default drain timeout
>   of 10 s would give unacceptable pauses.
> 
> - If an Rx stall was detected and the internal Rx queue is drained,
>   then the Rx thread would never wake.
> 
> Handle these two cases (when feature-rx-notify is disabled) by:
> 
> - Reducing the drain timeout to 30 ms.
> 
> - Disabling Rx stall detection.
> 
> Reported-by: John <jw@nuclearfallout.net>
> Tested-by: John <jw@nuclearfallout.net>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

FYI I've seen a report[0] that "Windows 2012 R2 domu with GPLPV drivers"
also suffered without feature-rx-notify support in the backend.

Ian.

[0] https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=767261#103
