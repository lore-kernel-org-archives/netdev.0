From: "Paul Albrecht" <palbrecht@qwest.net>
Subject: Re: question about linux tcp request queue handling
Date: Mon, 7 Jul 2003 21:14:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001501c34507$7a19baa0$6801a8c0@oemcomputer>
References: <3F08858E.8000907@us.ibm.com.suse.lists.linux.kernel><001a01c3441c$6fe111a0$6801a8c0@oemcomputer.suse.lists.linux.kernel><3F08B7E2.7040208@us.ibm.com.suse.lists.linux.kernel><000d01c3444f$e6439600$6801a8c0@oemcomputer.suse.lists.linux.kernel><3F090A4F.10004@us.ibm.com.suse.lists.linux.kernel><001401c344df$ccbc63c0$6801a8c0@oemcomputer.suse.lists.linux.kernel> <p73fzliqa91.fsf@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, linux-kernel@vger.kernel.org,
   "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Andi Kleen" <ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen writes:

>
> The 4.4BSD-Lite code described in Stevens is long outdated.
>

I was referring to volume one subtitled: "The Protocols."  It doesn't
describe implementation and the examples are not limited to bsd-lite.

>
>All modern BSDs (and probably most other Unixes too) do it in a similar way
to what
> Nivedita described.
>

Linux doesn't operate in the manner  Nivedita describes ... the tcp layer on
the server side moves to the syn_recd state, but doesn't accept the ack back
from client. Instead it times out and sends its syn/ack back to the client
and again ignores the client's ack, ... Eventually, either there's room on
backlog queue and the server side moves to the established state or the
server side stops resending the its syn/ack.  This doesn't seem to make much
sense. If the tcp layer can send the syn/ack it seems like it should
probably respond to the client's ack.

>
>The keywords are "syn flood attack" and "DoS".
>

I'd be interested in a more specific reference detailing the changes
required to the listen syscall as a consequence of the changes required for
avoidance of syn flood attacks.  Thanks.
