From: Dave Jones <davej@redhat.com>
Subject: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Tue, 26 Aug 2008 12:37:19 -0400
Message-ID: <20080826163719.GA25066@redhat.com>
References: <bug-459782-176318@bugzilla.redhat.com> <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.w.r.degoede@hhs.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54273 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300AbYHZQir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 12:38:47 -0400
Content-Disposition: inline
In-Reply-To: <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just had this bug reported against our development tree..

	Dave

On Tue, Aug 26, 2008 at 11:49:31AM -0400, bugzilla@redhat.com wrote:
 > Please do not reply directly to this email. All additional
 > comments should be made in the comments box of this bug.
 > 
 > https://bugzilla.redhat.com/show_bug.cgi?id=459782
 > 
 > Hans de Goede <j.w.r.degoede@hhs.nl> changed:
 > 
 >            What    |Removed                     |Added
 > ----------------------------------------------------------------------------
 >                  CC|                            |j.w.r.degoede@hhs.nl
 >           Component|gkrellm                     |kernel
 >          AssignedTo|j.w.r.degoede@hhs.nl        |kernel-maint@redhat.com
 >             Summary|gkrellmd consumes about 75% |cat /proc/net/tcp takes 0.5
 >                    |cpu time                    |seconds on x86_64, 0.5
 >                    |                            |seconds !!
 > 
 > --- Comment #2 from Hans de Goede <j.w.r.degoede@hhs.nl>  2008-08-26 11:49:30 EDT ---
 > Thanks for reporting this some stracing of gkrellmd has found that reading from
 > /proc/net/tcp and reading from /proc/net/tcp6 is the culprit, try this on your
 > x86_64 machine to confirm:
 > 
 > "time cat /proc/net/tcp"
 > 
 > To give you an idea on my rawhide x86_64 machine:
 > [hans@localhost devel]$ time cat /proc/net/tcp
 > <snip>
 > real    0m0.520s
 > user    0m0.000s
 > sys     0m0.446s
 > 
 > Thats amazingly slow, esp as I only have 8 tcp connections open.
 > 
 > Some maybe usefull info: top reports a very high load (50%) from soft IRQ's.
 > 
 > Anyways changing this to a kernel bug.

-- 
http://www.codemonkey.org.uk
