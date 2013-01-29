From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: ks8851: convert to threaded IRQ
Date: Mon, 28 Jan 2013 20:33:51 -0800
Message-ID: <1359434031.4196.18.camel@joe-AO722>
References: <1358949098-17778-1-git-send-email-balbi@ti.com>
	 <20130128.223157.1855971357181002973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: balbi@ti.com, sboyd@codeaurora.org, mjr@cs.wisc.edu,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49983 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753323Ab3A2Edw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 23:33:52 -0500
In-Reply-To: <20130128.223157.1855971357181002973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-28 at 22:31 -0500, David Miller wrote:
> From: Felipe Balbi <balbi@ti.com>
> Date: Wed, 23 Jan 2013 15:51:38 +0200
[]
> > @@ -1505,7 +1485,8 @@ static int ks8851_probe(struct spi_device *spi)
[]
> > -     ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
> > +     ret = request_threaded_irq(spi->irq, NULL, ks8851_irq,
> > +                     IRQF_TRIGGER_LOW | IRQF_ONESHOT,
> >                         ndev->name, ks);
> 
> You need to indent the second and third line of this function call
> properly.  It should be:
> 
>         ret = function_call(arg1, arg2,
>                             arg3, arg4,
>                             arg5, arg6, etc.);

Instead of writing all these emails all the time,
maybe it'd be better to make the checkpatch messages
that are currently emitted only with the --strict
option (like parenthesis alignment) emitted whenever
working on files in drivers/net/ and net/.
---
 scripts/checkpatch.pl | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 9cec6dd..da1d15a 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -35,6 +35,8 @@ my $help = 0;
 my $configuration_file = ".checkpatch.conf";
 my $max_line_length = 80;
 
+my $realfile = '';
+
 sub help {
 	my ($exitcode) = @_;
 
@@ -1287,7 +1289,9 @@ sub WARN {
 	}
 }
 sub CHK {
-	if ($check && report("CHECK", $_[0], $_[1])) {
+	if ($realfile =~ m@^(drivers/net|net/)@) {
+		WARN($_[0], $_[1]);
+	} elsif ($check && report("CHECK", $_[0], $_[1])) {
 		our $clean = 0;
 		our $cnt_chk++;
 	}
@@ -1381,7 +1385,7 @@ sub process {
 	our $cnt_chk = 0;
 
 	# Trace the real file/line as we go.
-	my $realfile = '';
+	$realfile = '';
 	my $realline = 0;
 	my $realcnt = 0;
 	my $here = '';
