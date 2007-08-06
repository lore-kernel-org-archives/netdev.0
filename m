From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] docs: note about select in kconfig-language.txt
Date: Mon, 6 Aug 2007 13:51:31 +0200
Message-ID: <20070806115131.GB1973@ff.dom.local>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com> <20070731121735.GA1046@ff.dom.local> <46AF4F9C.5060000@googlemail.com> <20070801095920.GA1941@ff.dom.local> <20070802020219.GM11166@waste.org> <20070802093659.GB27748@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com,
	Satyam Sharma <satyam@infradead.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:59555 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755291AbXHFLvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 07:51:06 -0400
Content-Disposition: inline
In-Reply-To: <20070802093659.GB27748@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

If there are no other plans of kconfig docs update I think this
message of yours should be useful enough. I made minimal fixes,
so if they are wrong or you prefer it otherwise, I'm OK with any
change to this proposal, including replacement with something
else.

Thanks & regards,
Jarek P.

On Thu, Aug 02, 2007 at 11:36:59AM +0200, Sam Ravnborg wrote:
...
> > > seems to select NET_POLL_CONTROLLER after selecting NETPOLL, but
> > > still doesn't check for NETDEVICES dependency.
> > 
> > That's odd. Adding Sam to the cc:.
> 
> select is evil....
> select will by brute force set a symbol equal to 'y' without
> visiting the dependencies.
> So abusing select you are able to select a symbol FOO even 
> if FOO depends on BAR that is not set.
> 
> In general use select only for non-visible symbols (no promts anywhere)
> and for symbols with no dependencies.
> That will limit the suefullness but on the other hand avoid the illegal
> configurations all over.
> 
> kconfig should one day warn about such things but I have not fel inclined
> to dive into the matters hoping that Roman does one day.
> 
> 	Sam
> 
----------->

Subject: docs: a warning note about select in kconfig-language.txt

A warning note of Sam Ravnborg about kconfig's select evilness,
dependencies and the future (slightly corrected).

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
Cc: Sam Ravnborg <sam@ravnborg.org>

---

diff -Nu9r 2.6.23-rc1-/Documentation/kbuild/kconfig-language.txt 2.6.23-rc1/Documentation/kbuild/kconfig-language.txt
--- 2.6.23-rc1-/Documentation/kbuild/kconfig-language.txt	2007-07-09 01:32:17.000000000 +0200
+++ 2.6.23-rc1/Documentation/kbuild/kconfig-language.txt	2007-08-06 12:50:34.000000000 +0200
@@ -92,18 +92,27 @@
 
 - reverse dependencies: "select" <symbol> ["if" <expr>]
   While normal dependencies reduce the upper limit of a symbol (see
   below), reverse dependencies can be used to force a lower limit of
   another symbol. The value of the current menu symbol is used as the
   minimal value <symbol> can be set to. If <symbol> is selected multiple
   times, the limit is set to the largest selection.
   Reverse dependencies can only be used with boolean or tristate
   symbols.
+  Note:
+	select is evil.... select will by brute force set a symbol
+	equal to 'y' without visiting the dependencies. So abusing
+	select you are able to select a symbol FOO even if FOO depends
+	on BAR that is not set. In general use select only for
+	non-visible symbols (no promts anywhere) and for symbols with
+	no dependencies. That will limit the usefulness but on the
+	other hand avoid the illegal configurations all over. kconfig
+	should one day warn about such things.
 
 - numerical ranges: "range" <symbol> <symbol> ["if" <expr>]
   This allows to limit the range of possible input values for int
   and hex symbols. The user can only input a value which is larger than
   or equal to the first symbol and smaller than or equal to the second
   symbol.
 
 - help text: "help" or "---help---"
   This defines a help text. The end of the help text is determined by
