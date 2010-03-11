From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: Fw: [Bug 15517] New: big file transfers stall and break
 network
Date: Thu, 11 Mar 2010 14:31:09 -0800
Message-ID: <20100311223109.GA4964@xw6200.broadcom.net>
References: <20100311084630.64b85696@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1587 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756499Ab0CKWbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 17:31:24 -0500
In-Reply-To: <20100311084630.64b85696@nehalam>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 11, 2010 at 08:46:30AM -0800, Stephen Hemminger wrote:
> 
> 
> Begin forwarded message:
> 
> Date: Thu, 11 Mar 2010 14:40:12 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 15517] New: big file transfers stall and break network
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=15517
> 
>            Summary: big file transfers stall and break network
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32.9
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: conrad_s@rocketmail.com
>         Regression: Yes
> 
> 
> Created an attachment (id=25475)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=25475)
> lspci output, from working 2.6.31
> 
> Upgrading to kernel 2.6.32.9 on a 64-bit machine (Fedora 12,
> 2.6.32.9-67.fc12.x86_64) caused breakage in transfer of large files over SSH
> and SMB, followed by breaking network access.
> 
> To reproduce, copy a large file (> 900 MB) using SSH or SMB (mounted either
> directly via "mount" or indirectly via "gfvs / nautilus").  Copy stalls and
> network becomes unusable (e.g. can't ssh to any other host).
> 
> Previous kernel 2.6.31.12 (Fedora 12, 2.6.31.12-174.2.22.fc12.x86_64) works
> fine.

This is a 5906 chip bug that was exposed.  Commit
92c6b8d16a36df3f28b2537bed2a56491fb08f11 fixes the problem.  Mike Pagano
has already submitted this fix to stable.

