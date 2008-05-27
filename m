From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: possible double call of kfree_skb in net/llc/llc_sap.c
Date: Tue, 27 May 2008 09:20:06 +0300
Message-ID: <84144f020805262320k5740cd25lf16d7838d5358f0b@mail.gmail.com>
References: <84ee89da0805262300v747c712ayfb60ac8aa790edb7@mail.gmail.com>
	 <483BA72B.5010207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Petukhov" <dmgenp@gmail.com>, linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:63942 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301AbYE0GUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 02:20:08 -0400
Received: by rv-out-0506.google.com with SMTP id l9so2772056rvb.1
        for <netdev@vger.kernel.org>; Mon, 26 May 2008 23:20:07 -0700 (PDT)
In-Reply-To: <483BA72B.5010207@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Petukhov wrote:
>> In the file  net/llc/llc_sap.c, funcion llc_sap_state_process,
>> the call to kfree_skb in the line 227 can proceed even if skb was already
>> freed
>> on line 218, or  224, or queued to the user within sock_queue_rcv_skb
>> function.
>> Obviously return statement is missing after line 225.
>>
>> This problem was found by Alex Shevkov.

On Tue, May 27, 2008 at 9:16 AM, Patrick McHardy <kaber@trash.net> wrote:
> Could you send a patch please?

I wonder how the code got in that shape but it's probably best to just
remove the extra kfree_skb() calls and do it unconditionally at the
end of the function.
