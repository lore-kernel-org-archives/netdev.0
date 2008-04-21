From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] [TC/U32] Infrastructure for pretty printing
Date: Mon, 21 Apr 2008 15:29:55 +0200
Message-ID: <480C96D3.5050809@trash.net>
References: <1208702964.12249.57.camel@localhost>	 <480C8006.3060708@trash.net> <1208784237.12249.181.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40587 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762290AbYDUNaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 09:30:02 -0400
In-Reply-To: <1208784237.12249.181.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Mon, 2008-21-04 at 13:52 +0200, Patrick McHardy wrote:
> 
>> So far the dump output can be cut-and-pasted and is
>> properly parsed again (useful for example for deletion).
>> Does that still work with pretty printing?
> 
> great idea;-> 
> It doesnt do that at the moment - all it tries to do is be equivalent to
> the raw format (example the prefix "match" etc).
> I think it is worth it though to try what you suggest and i will look
> into it and provide an additional patch on top.
> IINMistaken you are thinking of a save/restore feature?

Something like that. But it used to already work the
way I described, at least for all parts where I tested
it so far (IIRC routes/rules/addresses/qdiscs/classes/filters).

> The main challenge would be the cruft that dumps at the begining i.e the
> sort of:
> --
> filter protocol ip pref 10 u32
> filter protocol ip pref 10 u32 fh 802: ht divisor 1
> filter protocol ip pref 10 u32 fh 802::800 order 2048 key ht 802 bkt 0
> flowid 1:12
> ---

Yes, the first part needs to be stripped (filter/qdisc/class/...).
I usually do something like

"ip link/route/addr del <paste dump without first word here>".

Similar for tc.

> I am wondering in the case of -c if we should also go all the way and
> dump just sufficient info to be able to reuse it as is to re-insert or
> alternatively dump as it is today (for the lines above) and the restore
> script would extract enough details out of the above.
> Thoughts?


It would be nice to dump it in a format that can be piped
into batch mode without further changes, so it would have
to insert "add" between "filter" and "protocol".
