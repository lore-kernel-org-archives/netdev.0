From: BJ Cran <s9905155@sms.ed.ac.uk>
Subject: ipv4 /proc/net/route bug in 2.4 and 2.5 kernels
Date: Thu, 31 Oct 2002 12:13:05 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1036066385.3dc11e51d11ab@sms.ed.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I've discovered a bug in the 2.4 and 2.5 kernels relating to the
information in /proc.   The values reported in /proc/net/route are wrong -
the main error is the MTU field which should be MSS, and should be the
MTU-40.  The route command has the header fixed, but still gets the value
from /proc, and so reports the wrong value of
40.

I'm currently using 2.5.43, and have tracked it down to line 1031 in
net/ipv4/fib_semantics.c in function fib_node_seq_show.  It appears that
fi->fib_advmss is 0, because when I change the '+40' to '+45' that is the
value which appears in the MTU field in /proc/net/route, and in the MSS
field when running '/sbin/route -e'.

Also, on line 191 of net/ipv4/ip_proc.c (in function fib_seq_show), I
think the 'MTU' should be 'MSS' according to the comments in route.c, and
to make the output of the route command and the proc entry consistent.

I've also posted this bug report to the lkml, but haven't had any reply.
 I realise that it isn't a priority with more serious bugs in 2.5 needing
fixed, but it would be nice to get the information correct, especially
since
this bug has been around since the 2.4-pre kernels.

Thanks.

--
Bruce Cran
