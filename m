From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/5] genetlink: statically initialize families
Date: Tue, 25 Oct 2016 13:38:28 +0200
Message-ID: <1477395508.4390.23.camel@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
         <1477312805-7110-4-git-send-email-johannes@sipsolutions.net>
         (sfid-20161024_144032_073312_7524B853) <1477313733.4085.11.camel@sipsolutions.net>
         <063D6719AE5E284EB5DD2968C1650D6DB0209D95@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36242 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752711AbcJYLif (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 07:38:35 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0209D95@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-25 at 11:25 +0000, David Laight wrote:

> > Actually, with the new system where it's not const, I could even
> > split this up and submit per subsystem, i.e. the fourth patch
> > doesn't depend on it. I thought it would, since I wanted to make it
> > const, but since I failed it doesn't actually have that dependency.
> 
> Actually, why aren't the structures 'const' ?
> 
> You could use a #define to set the .ops and .n_ops fields.
> (and maybe .module = THIS_MODULE as well).

This stuff isn't the problem - after this patch these are of course
statically initialized and const.

The problem is that the struct members family->id, family->mcgrp_offset 
and family->attrbuf, are only determined at genl_register_family().

I considered simply moving them into a new struct, that contains just
those along with a pointer to the family, but then I have essentially
two choices:

1) look up the registration struct by the family every time I need the
   family ID, which is all the time; that would be rather inefficient

2) change *all* genetlink code to not pass the family but rather pass a
   pointer returned by genl_register_family(); that's a massive change

So on the whole, I decided that __ro_after_init was entirely reasonable
and then even this patch isn't really necessary, but since I had it
anyway it still seemed to make sense, even if I had to add all those
forward declarations.

johannes
