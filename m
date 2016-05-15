From: Guy Harris <guy@alum.mit.edu>
Subject: Re: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time stamping?
Date: Sat, 14 May 2016 19:11:50 -0700
Message-ID: <B32E7BAF-090F-4D9F-A519-B96AF2FD0EF0@alum.mit.edu>
References: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu> <20160514073002.GA2053@netboy> <4AAA3CE1-B137-4AC1-AB85-B4690E8E3E12@alum.mit.edu> <20160514202653.GA6529@netboy>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:60216 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753994AbcEOCLz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 22:11:55 -0400
In-Reply-To: <20160514202653.GA6529@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 14, 2016, at 1:26 PM, Richard Cochran <richardcochran@gmail.com> wrote:

> On Sat, May 14, 2016 at 11:47:22AM -0700, Guy Harris wrote:
>> So if you have a GUI application for packet capture, with a combo box to select the type of time stamping, should it:
>> 
>> 	1) regardless of whether ETHTOOL_GET_TS_INFO is available, open the adapter, try each of the time stamp types to see whether it works, and show a combo box based on that;
>> 
>> 	2) use ETHTOOL_GET_TS_INFO if available;
>> 
>> 	3) offer all possibilities regardless of whether they work with the adapter or not, and just report an error for possibilities that don't work?
>> 
>> My preference is 2) - which is the main reason why libpcap offers "what possibilities are available?" APIs, not just "request this possibility" APIs.
> 
> You are going to have to implement #1 in any case, if you want your
> program to work on all kernels.

What libpcap currently implements is a combination of #2 and #3, where:

	if it's compiled with headers that define ETHTOOL_GET_TS_INFO, it tries to do ETHTOOL_GET_TS_INFO and, if that fails with EOPNOTSUPP or EINVAL, it offers all possibilities;

	if it's compiled with headers that don't define it, it just offers all possibilities.

It could do a combination of #2 and #1, where "offers all possibilities" is replaced by "opens the adapter, tries each of the possibilities, and offers the ones that don't fail" - but, other than the current bugs with ETHTOOL_GET_TS_INFO, I don't see any advantage to doing only #1, rather than trying #2, perhaps with some special-casing to work around the bugs in question, and only falling back on actually trying to set the options if we can't ask about them.
