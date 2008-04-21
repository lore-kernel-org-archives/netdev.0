From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [TC/U32] Infrastructure for pretty printing
Date: Mon, 21 Apr 2008 10:15:55 -0400
Message-ID: <1208787355.12249.199.camel@localhost>
References: <1208702964.12249.57.camel@localhost>
	 <480C8006.3060708@trash.net> <1208784237.12249.181.camel@localhost>
	 <480C96D3.5050809@trash.net>  <1208786335.12249.194.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:30253 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbYDUOQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 10:16:27 -0400
Received: by gv-out-0910.google.com with SMTP id s4so74363gve.37
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 07:16:25 -0700 (PDT)
In-Reply-To: <1208786335.12249.194.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-21-04 at 09:59 -0400, jamal wrote:
> On Mon, 2008-21-04 at 15:29 +0200, Patrick McHardy wrote:
> 
> > Something like that. But it used to already work the
> > way I described, at least for all parts where I tested
> > it so far (IIRC routes/rules/addresses/qdiscs/classes/filters).
> 
> ok, missed that - i dont recall ever using it like that. But i will test
> and make sure it works. Now i get more of what you are saying with the
> env variables.
> 
> > Yes, the first part needs to be stripped (filter/qdisc/class/...).
> > I usually do something like
> > 
> > "ip link/route/addr del <paste dump without first word here>".
> > 
> > Similar for tc.
> 
> Ok, just tried it on my laptop; u32 (and maybe the rest of the filters)
> doesnt work in this mode. Essentially inputting is of the form
> "match u{8,16,32} value mask" and output is of form "match
> 32bitval/32bitmask"

Actually it is easy to fix but it may break existing scripts again.
Certainly will break mine. The simple solution would be:
Change output which goes like:

-------
match 00000000/00ff0000 at 4
-----

to

---------
match 00000000 00ff0000 at 4
---

So maybe just make sure the cooked mode works in the future and ignore
all the rest. Or for the raw format (when someone explicitly calls it
with -raw) output it with the space instead of /.

cheers,
jamal

