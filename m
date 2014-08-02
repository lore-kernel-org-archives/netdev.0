From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Fri, 01 Aug 2014 21:55:27 -0700
Message-ID: <lrhr02$ncj$1@ger.gmane.org>
References: <1406856100-21674-1-git-send-email-pmoody@google.com> <87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Moody wrote:

<snip>
> One thing that Hone does which snet doesn't seem to do (apologies if
> this is incorrect but I can't test) is that it provides a full process
> tree for a given pid back to init. When doing an investigation into a
> system compromise, knowing what started the process making the
> suspicious connection(s) (and what started *that* process) is often just
> as important as knowing that there's a compromise to begin with.

Out of curiosity, have you looked at Tomoyo much at all? In particular, it:

1.) Keeps a tree all the way back to init
2.) Has network event hooks (see footnote [1])
3.) Has an interactive API for managing policy violations (tomoyo-queryd[2] 
uses it)
4.) Is in mainline already.

The combination is actually sufficient to implement what you want for Hone 
_today_ as far as I can tell, and there's even the out-of-tree AKARI variant 
if you want to use it together with another LSM.

There's also Caitsith[3] (also from Tetsuo Handa), which might be even 
better suited but is not in mainline yet.

[1] It has these hooks for inet sockets, and similar for unix:
network inet stream bind $ADDRESS $PORT
network inet stream listen $ADDRESS $PORT
network inet stream connect $ADDRESS $PORT
network inet dgram bind $ADDRESS $PORT
network inet dgram send $ADDRESS $PORT
network inet raw bind $ADDRESS $PROTOCOL
network inet raw send $ADDRESS $PROTOCOL

See http://tomoyo.sourceforge.jp/2.5/policy-specification/domain-policy-syntax.html.en#network_inet

[2] http://tomoyo.sourceforge.jp/2.5/man-pages/tomoyo-queryd.html.en
[3] http://caitsith.sourceforge.jp/

