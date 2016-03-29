From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: ss filter problem
Date: Tue, 29 Mar 2016 23:05:19 +0300
Message-ID: <20160329200519.GA15515@angus-think.lan>
References: <20160329193242.GA28502@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, Vadim Kochan <vadim4j@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:33633 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758108AbcC2UMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 16:12:23 -0400
Received: by mail-lb0-f175.google.com with SMTP id u8so18370045lbk.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 13:12:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160329193242.GA28502@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil,

On Tue, Mar 29, 2016 at 09:32:42PM +0200, Phil Sutter wrote:
> Hi,
> 
> I am trying to fix a bug in ss filter code, but feel quite lost right
> now. The issue is this:
> 
> | ss -nl -f inet '( sport = :22 )'
> 
> prints not only listening sockets (as requested by -l flag), but
> established ones as well (reproduce by opening ssh connection to
> 127.0.0.1 before calling above).
> 
> In contrast, the following both don't show the established sockets:
> 
> | ss -nl '( sport = :22 )'
> | ss -nl -f inet
> 
> My investigation led me to see that current_filter.states is altered
> after ssfilter_parse() returns, and using gdb with a watchpoint I was
> able to identify parse_hostcond() to be the bad guy: In line 1560, it
> calls filter_af_set() after checking for fam != AF_UNSPEC (which is the
> case, since fam = preferred_family and the latter is changed to AF_INET
> when parsing '-f inet' parameter).

Yes, after removing of fam != AF_UNSPEC body - it works, because
it does not overwrite specified states (-l) from command line, but I
can't say what it may affect else, I will try to investigate it better.

> 
> This whole jumping back and forth confuses me quite effectively. Since
> you did some fixes in the past already, are you possibly able to point
> out where/how this tiny mess has to be fixed?
> 
> I guess in an ideal world we would translate '-l' to 'state listen', '-f
> inet' to 'src inet:*' and pass everything ANDed together to
> ssfilter_parse(). Or maybe that would make things even worse. ;)
> 
> Cheers, Phil

I thought I fixed & tested well ss filter, but seems it would be good to
have good automation testing.

Regards,
Vadim Kochan
