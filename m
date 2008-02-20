From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks with	__maybe_unused
Date: Wed, 20 Feb 2008 16:35:34 +0100
Message-ID: <47BC48C6.3050208@trash.net>
References: <47BC3303.2040101@openvz.org>	 <1203521357.7181.163.camel@localhost> <1203521514.7181.167.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51967 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933149AbYBTPfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:35:45 -0500
In-Reply-To: <1203521514.7181.167.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Wed, 2008-02-20 at 07:29 -0800, Joe Perches wrote:
>   
>> fs/nfsd/nfsproc.c:              char buf[RPC_MAX_ADDRBUFLEN];
>> Perhaps there should be a DECLARE_RPC_BUF(buf) macro?
>> #define DECLARE_RPC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
>>     
>
> Make that:
>
> #define DECLARE_RPC_BUF(var) char var[RPC_MAX_ADDRBUFLEN] __maybe_unuse

Alternatively change the dprintk macro to behave similar like
pr_debug() and mark things like svc_print_addr() __pure, which
has the advantage that is still performs format checking even
if debugging is disabled.

