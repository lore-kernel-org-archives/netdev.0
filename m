From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] tipc: set sk_err correctly when connection fails
Date: Tue, 27 Aug 2013 14:12:07 -0400
Message-ID: <521CEBF7.4040103@windriver.com>
References: <1377266200-26691-1-git-send-email-erik.hugne@ericsson.com> <521CA797.2010109@windriver.com> <20130827151841.GE1939@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>,
	<nhan.tt.vo@dektech.com.au>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43456 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab3H0SMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 14:12:17 -0400
In-Reply-To: <20130827151841.GE1939@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-08-27 11:18 AM, Erik Hugne wrote:
> On Tue, Aug 27, 2013 at 09:20:23AM -0400, Paul Gortmaker wrote:
>> What was the high level user visible symptom in this case?
>> Stalled connections or ... ?
> 
> Should the connect fail, if the publication/server is unavailable or some other
> error. The connect() call returns the error code directly (as a positive value).

Please send a v2 with the end-user visible symptom clearly described;
as this information is what people use in order to triage whether
commits belong in stable, or net vs. net-next etc.   For example:

  Should the connect fail, say if the publication/server is unavailable or
  some other error, then the code returns a positive return value.  Since
  most code only checks for a negative return on connect(), it tries to
  continue, but will ultimately fail on the 1st sendto() as the strace
  snippet below shows.

I've said "most code" since I simply don't know what it was that you were
tracing below.  It would help if we knew if this part of a common application
or similar.

Thanks,
Paul.
--

> 
> [...]
> socket(0x1e /* PF_??? */, SOCK_SEQPACKET, 0) = 3
> setsockopt(3, 0x10f /* SOL_?? */, 129, [0], 4) = 0
> setsockopt(3, 0x10f /* SOL_?? */, 127, [0], 4) = 0
> connect(3, {sa_family=0x1e /* AF_??? */, sa_data="\2\1\322\4\0\0\322\4\0\0\0\0\0\0"}, 16) = 111
> sendto(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 66000, 0, NULL, 0) = -1 EPIPE (Broken pipe)
> 
> In the strace above, error checking was done as:
> if (connect(fd,.....) < 0)
>     perror("connect");
> 
> //E
> 
