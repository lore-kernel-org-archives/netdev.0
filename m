From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv3 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Mon, 28 Apr 2008 22:12:02 +0200
Message-ID: <200804282212.03453.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <20080428131047.GB14346@gerrit.erg.abdn.ac.uk> <20080428151955.GC27604@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:3074 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935276AbYD1UMU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 16:12:20 -0400
In-Reply-To: <20080428151955.GC27604@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Monday 28 of April 2008, Gerrit Renker napisa=B3:
> Here is a tidied-up version, the patch sent last week and stored in
>
> 	git://eden-feed.erg.abdn.ac.uk/dccp_exp (tree `qpolicy')
>
> was not very good, the updates are:
>
>  * the skb->priority is now cleared when leaving the DCCP layer;
Ok. I only wonder if this kind of cleanup shouldn't happen in qpolicy s=
pecific=20
function. Such as already non-existant qpolicy_prio_pop(). Note that=20
qpolicy_simple_pop() would not need to clear skb->priority. This kind o=
f=20
function could act as skb deinitializer. And I think qpolicy_*_pop() sh=
ould=20
be added again...

The same question applies to skb initialization. In my opinion it shoul=
d=20
happen in qpolicy_*_push(). So that dccp_msghdr_parse code should be mo=
ved=20
there.

This approach would clearly abstract qpolicy subsystem from the rest of=
 dccp=20
code. We would have packet initialization in qpolicy_*_push() and=20
deinitialization in qpolicy_*_pop().

I'll try to write a patch that demonstrates it.

>  * there is now documentation/hints about the use of skb->priority in=
 DCCP;
There is something I don't understand in your approach regarding=20
skb->priority. I think I could understand it better it you could sketch=
 how=20
in your opinion should an interface look like if packet timeout was to =
be=20
added.
Would you:
a) pack this data into this u32 identified by DCCP_SCM_PRIORITY. This i=
s what=20
I thought you meant (but I may be wrong). And something I don't really =
like.
b) add another parameter type eg. DCCP_SCM_TIMEOUT_MS and use another u=
32 to=20
pass this parameter. This is something I like much better,
c) something else. Then what is that?

>  * there is one question I have, and that can be reverted:
>    - qpolicy_prio_push() has been replaced by a combination of
>    - qpolicy_prio_full() [which now does the drop-on-queue-full] and
>      qpolicy_simple_push() [which does the FIFO-queueing]
>    This means fewer routines, but if you don't like it, I am ok to re=
vert
> it.
>
I don't care that much about internal implementation. But I don't reall=
y like=20
mixing policies. Especially since when prio policy will have more featu=
res=20
these functions will have to be separated again. When making any choice=
s I=20
always try to think how it will look like when more features are added=20
(especially packet timeouts and getting statistics).
--=20
Regards,
Tomasz Grobelny
