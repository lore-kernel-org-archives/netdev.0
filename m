From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V4] tc: flower: Refactor matching flags to be
 more user friendly
Date: Fri, 20 Jan 2017 17:41:14 +0100
Message-ID: <20170120174114.183f6e81@griffin>
References: <1484835468-46051-1-git-send-email-paulb@mellanox.com>
        <20170119152218.61aa2fc4@griffin>
        <063D6719AE5E284EB5DD2968C1650D6DB0268D18@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Blakey <paulb@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41794 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752611AbdATQld (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 11:41:33 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0268D18@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 12:27:42 +0000, David Laight wrote:
> Consider what happened with "no", "nofubar" and "nofubar_baz",
> all ought to be rejected.

Why? "no" translates to "", "nofubar" to "fubar", etc. And those will
be evaluated the same way as if they were supplied without the "no".
I don't see a problem with this.

> Actually using strncmp() is also overkill.

Why? It compares two bytes. There's an extra null at the end of the
"no" string but I wouldn't call that "overkill".

> Nothing wrong with:
> 	if (token[0] == 'n' && token[1] == 'o' && token[2]) {

Except that strncmp is easier to understand and cleaner.

> 		no = true;
> 		token += 2;
> 		if (token[0] == '_' && token[1])
> 			token++;

This doesn't make sense. The intent was not to allow both "nofrag" and
"no_frag". The code in the patch treats "no_frag" as invalid and that's
okay.

> 		...
> 
> or replace the last 3 lines with:
> 		token += 2 + (token[2] == '_' & token[3]);

That's horribly ugly. Anyone looking at this will spent 2 minutes
trying to untangle the code instead of the 2 seconds with the current
code. We're not trying to win the Obfuscated C Contest here.

 Jiri
