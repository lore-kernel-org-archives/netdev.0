From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] list.h: add list_for_each_struct_entry macro
Date: Mon, 18 Jan 2010 22:30:29 +0100
Message-ID: <20100118213028.GD4521@psychotron.redhat.com>
References: <20100118162338.GD4229@psychotron.lab.eng.brq.redhat.com>
 <1263835033.3667.23.camel@achroite.uk.solarflarecom.com>
 <20100118210718.GC4521@psychotron.redhat.com>
 <1263849258.3667.43.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755761Ab0ARVas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 16:30:48 -0500
Content-Disposition: inline
In-Reply-To: <1263849258.3667.43.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 18, 2010 at 10:14:18PM CET, bhutchings@solarflare.com wrote:
>On Mon, 2010-01-18 at 22:07 +0100, Jiri Pirko wrote:
>> Mon, Jan 18, 2010 at 06:17:13PM CET, bhutchings@solarflare.com wrote:
>[...]
>> >#define list_for_each_struct_entry(pos, head, type, posmember, member)	     \
>> >	for (pos = list_empty(head) ? NULL :				     \
>> >		&list_first_entry(head, type, member)->posmember;	     \
>> >	     prefetch(container_of(pos, type, posmember)->member.next), pos; \
>> >	     pos = list_is_last(&container_of(pos, type, posmember)->member, \
>> >				head) ?	NULL :				     \
>> >		&list_entry(container_of(pos, type, posmember)->member.next, \
>> >			    type, member)->posmember)
>> >
>> 
>> At the first glance, this would take even more cputime for lists longer
>> than 2 or so, wouldn't it?
>
>If you're concerned about speed, measure it, don't guess.

Well I just see extra code
"list_is_last(&container_of(pos, type, posmember)->member, head)"
to be done in each iteration. Also I do not see additional value in doing this.
(Unlike in checking list_empty(head)).

Anyway, if you want to use this optimization, I guess more code in list.h could
use this.

Jirka
>
>Ben.
>
>-- 
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
