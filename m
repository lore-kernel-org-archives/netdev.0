From: Guy Harris <guy@alum.mit.edu>
Subject: Re: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time stamping?
Date: Sat, 14 May 2016 11:47:22 -0700
Message-ID: <4AAA3CE1-B137-4AC1-AB85-B4690E8E3E12@alum.mit.edu>
References: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu> <20160514073002.GA2053@netboy>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:32776 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215AbcENSr0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 14:47:26 -0400
In-Reply-To: <20160514073002.GA2053@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 14, 2016, at 12:30 AM, Richard Cochran <richardcochran@gmail.com> wrote:

> On Fri, May 13, 2016 at 04:12:52PM -0700, Guy Harris wrote:
>> The Linux implementation currently implements the inquiry by doing a
>> ETHTOOL_GET_TS_INFO SIOETHTOOL ioctl and looking at the
>> so_timestamping bits, if the linux/ethtool.h header defines
>> ETHTOOL_GET_TS_INFO and the ioctl succeeds on the device.
> 
> So far, so good. 
> 
>> This is inadequate - as libpcap requests hardware time stamping for
>> all packets, it should also check whether HWTSTAMP_FILTER_ALL is set
>> in rx_filters, and only offer hardware time stamping if it's set.
> 
> The SO_TIMESTAMPING and SIOCSHWTSTAMP interfaces predate
> ETHTOOL_GET_TS_INFO, and they work fine without it.  Applications
> should simply use SIOCSHWTSTAMP to request the mode that they need and
> check the result.

So if you have a GUI application for packet capture, with a combo box to select the type of time stamping, should it:

	1) regardless of whether ETHTOOL_GET_TS_INFO is available, open the adapter, try each of the time stamp types to see whether it works, and show a combo box based on that;

	2) use ETHTOOL_GET_TS_INFO if available;

	3) offer all possibilities regardless of whether they work with the adapter or not, and just report an error for possibilities that don't work?

My preference is 2) - which is the main reason why libpcap offers "what possibilities are available?" APIs, not just "request this possibility" APIs.
