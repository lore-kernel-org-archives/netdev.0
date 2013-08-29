From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH v2] tipc: set sk_err correctly when connection fails
Date: Thu, 29 Aug 2013 11:03:10 -0400
Message-ID: <521F62AE.40101@windriver.com>
References: <1377674998-18872-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ying.xue@windriver.com>,
	<jon.maloy@ericsson.com>, <tipc-discussion@lists.sourceforge.net>,
	<nhan.tt.vo@dektech.com.au>
To: <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64703 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699Ab3H2PDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 11:03:20 -0400
In-Reply-To: <1377674998-18872-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-08-28 03:29 AM, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Should a connect fail, if the publication/server is unavailable or
> due to some other error, a positive value will be returned and errno
> is never set. If the application code checks for an explicit zero
> return from connect (success) or a negative return (failure), it
> will not catch the error and subsequent send() calls will fail as
> shown from the strace snippet below.
> 
> socket(0x1e /* PF_??? */, SOCK_SEQPACKET, 0) = 3
> connect(3, {sa_family=0x1e /* AF_??? */, sa_data="\2\1\322\4\0\0\322\4\0\0\0\0\0\0"}, 16) = 111
> sendto(3, "test", 4, 0, NULL, 0)        = -1 EPIPE (Broken pipe)
> 
> The reason for this behaviour is that TIPC wrongly inverts error
> codes set in sk_err.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> ---
> 
> [v2: add more details to commit message]

Thanks -- this now conveys the required triplet: 1) user visible symptom,
2) underlying technical cause, and 3) the why and how of the fix.

Paul.
--
