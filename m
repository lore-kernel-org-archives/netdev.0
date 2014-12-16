From: rapier <rapier@psc.edu>
Subject: [PATCH net-next 0/3] Implementation of RFC 4898 Extended TCP Statistics
 (Web10G)
Date: Tue, 16 Dec 2014 12:49:59 -0500
Message-ID: <549070C7.5070505@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:39691 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbaLPRuC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 12:50:02 -0500
Received: from CMU-785477.WV.CC.CMU.EDU (CMU-785477.WV.CC.CMU.EDU [128.237.173.182])
	(authenticated bits=0)
	by mailer2.psc.edu (8.13.8/8.13.8) with ESMTP id sBGHnxEm012570
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 12:50:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch increments and/or update select RFC 4898 (TCP=20
Extended Statistics MIB) metrics within the TCP stack; we refer to this=
=20
as the Kernel Instrument Set (or KIS).  The goal of RFC 4898 is to=20
expose advanced statistics from TCP=92s vantage point to userland in or=
der=20
to help diagnose performance problems in both the network and=20
application. The metrics are gathered and cached within structures=20
defined in our header file (tcp_estats.h) on a per connection basis=20
allowing for highly detailed analysis of all TCP flows. More informatio=
n=20
can be found at http://www.web10g.org/

Note, the KIS does not integrate any specific ABI. This allows for a
clear separation between the kernel instruments and the methodology use=
d
to make the metrics available to userland. Currently, we have a netlink
implementation available as a DLKM and an associated API available at
https://sourceforge.net/projects/tcpestats/files/

Performance analysis provided by the kernel development teams at Google
and Facebook indicate that the overhead imposed when the KIS is
configured active and exposed via an ABI are minimal.  Facebook related
performance impacts of between 0% and 2%, depending on the the frequenc=
y
of polling the KIS via ftrace.  Analysis performed at Google indicate
similar performance characteristics.

Since the size of the KIS patch set is considerable (~2k lines), we hav=
e
broken it up into two components, the first provides our structures and=
=20
macros to the TCP networking DLKMs. The second provides the routines=20
that manage and control the TCP Extended Statistics, as well as=20
providing hooks for configuring and enabling the KIS. Each set of=20
patches patches, compiles, and runs independently. However, full=20
functionality requires both patch sets to be installed.

We took this approach because the control and management (C&M) routines=
=20
are, in our view, of secondary importance to the actual instrumentation=
=2E=20
As such, we did not want any issues with the C&M methods to impact the=20
adoption of the KIS. There is overlap between the two patch sets=20
(specifically the header files in the C&M) which will likely make=20
applying the C&M patch cleanly on top of the KIS patch problematic. As=20
such, I've also included a concatenated patch that includes both the KI=
S=20
and the C&M for evaluation.

A git repo is available at http://github.com/rapier/web10g The
net-next branch contains the instrumentation (1st patch set) and the
control and management (2nd patch set). The API is also available at
http://github.com/rapier1/web10g-userland

Chris Rapier
