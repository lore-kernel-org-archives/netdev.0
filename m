From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks with	__maybe_unused
Date: Wed, 20 Feb 2008 19:27:57 +0300
Message-ID: <47BC550D.7040003@openvz.org>
References: <47BC3303.2040101@openvz.org>	 <1203521357.7181.163.camel@localhost> <1203521514.7181.167.camel@localhost> <47BC48C6.3050208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42514 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934464AbYBTQ2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:28:04 -0500
In-Reply-To: <47BC48C6.3050208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Joe Perches wrote:
>> On Wed, 2008-02-20 at 07:29 -0800, Joe Perches wrote:
>>   
>>> fs/nfsd/nfsproc.c:              char buf[RPC_MAX_ADDRBUFLEN];
>>> Perhaps there should be a DECLARE_RPC_BUF(buf) macro?
>>> #define DECLARE_RPC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
>>>     
>> Make that:
>>
>> #define DECLARE_RPC_BUF(var) char var[RPC_MAX_ADDRBUFLEN] __maybe_unuse

OK, I'll send the patch in a moment.

> Alternatively change the dprintk macro to behave similar like

This is too heavy. The problem is that some arguments passed to this
function exist only under appropriate ifdefs, so having a static
inline there will produce a warning :(

> pr_debug() and mark things like svc_print_addr() __pure, which
> has the advantage that is still performs format checking even
> if debugging is disabled.

Taking my above statement into account, this becomes useless, since
svc_print_addr() is used inside those "empty" macros and are complied
out automatically.

> 

