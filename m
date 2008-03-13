From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10201] New: Yum update of Kernel broke sis900
	ethernet driver
Date: Thu, 13 Mar 2008 11:03:12 +0000
Message-ID: <20080313110312.GA4764@ff.dom.local>
References: <20080308155052.81cf3c8b.akpm@linux-foundation.org> <20080311091928.GA5765@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Dan McNaul <dmcnaul@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:47851 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbYCMLBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:01:42 -0400
Received: by ug-out-1314.google.com with SMTP id z38so425067ugc.16
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 04:01:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080311091928.GA5765@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2008 at 09:19:28AM +0000, Jarek Poplawski wrote:
> On 09-03-2008 00:50, Andrew Morton wrote:
> > On Sat,  8 Mar 2008 15:36:55 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> > 
> >> http://bugzilla.kernel.org/show_bug.cgi?id=10201
> ...
> >> Problem Description:  After reboot following YUM update to new kernel - SiS 900
> >> PCI Fast Ethernet (driver sis900) can not ifconfig eth0.  Configuration fails
> >> with  message "SIOCSIFFLAGS: Invalid argument".  System does boot. [...]
...
> > What could cuase SIOCSIFFLAGS to newly return -EINVAL?

Second try: dev->validate_addr()?!

Dan, you don't have HW (MAC) address set on your card, and it's
verified since 2.6.23.

Check if it can be done in BIOS (if it's onboard card) or in some
Fedora config tool or file. To verify this idea try again in 2.6.24.3
something like this:

ifconfig eth0 hw ether 00:00:00:00:00:01
ifconfig eth0 192.168.0.108

Regards,
Jarek P.
