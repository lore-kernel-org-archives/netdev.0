From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Sat, 12 May 2012 07:24:07 +0200
Message-ID: <20120512052407.GB2190@netboy.at.omicron.at>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141122.GB3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
 <20120511051509.GA2170@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807794A06@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57136 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854Ab2ELFYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 01:24:19 -0400
Received: by bkcji2 with SMTP id ji2so2728621bkc.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 22:24:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB5807794A06@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 11, 2012 at 07:34:12PM +0000, Keller, Jacob E wrote:
> 
> Sorry for the spam here, but I looked at the ixgbe code, and found a
> solution. When ptp4l discovers a missing rx timestamp, it faults and
> then waits for 15 seconds until the fault is cleared. After this, it
> reopens the socket, and reruns the hwtstamp ioctl. This function
> actually does clear the tx/rx timestamps (just in case) So after a
> fault the values should end up being reset. Is this good enough?

Yes, for ptp4l, that will work, but this program is acting extremely
defensively in that situation. Not every user space program will
necessarily behave in the same way. The classic ptpd just ignores
packets with missing time stamps, IRRC.

Richard
