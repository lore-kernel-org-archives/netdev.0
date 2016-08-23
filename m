From: Joe Perches <joe@perches.com>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 13:34:05 -0700
Message-ID: <1471984445.3746.129.camel@perches.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <20160823.094029.1244944495918162255.davem@davemloft.net>
         <1471973727.13300.162.camel@decadent.org.uk>
         <20160823.112406.549221808236512285.davem@davemloft.net>
         <20160823200941.GB2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: ben@decadent.org.uk, luis.henriques@canonical.com,
        avijitnsec@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0110.hostedemail.com ([216.40.44.110]:33581 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752765AbcHWUgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:36:24 -0400
In-Reply-To: <20160823200941.GB2356@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 21:09 +0100, Al Viro wrote:
> On Tue, Aug 23, 2016 at 11:24:06AM -0700, David Miller wrote:
> > > On some versions and architectures.  Can you guarantee that you will
> > > notice when an exception appears?
> > Again, show me the assembler output exhibiting the lack of
> > initialization, for this specific structure and situation.
> > 
> > That's all that I'm asking.
> ... and then we can file a bug report against the sodding compiler.  Note
> that
> struct ethtool_wolinfo {
>         __u32   cmd;
>         __u32   supported;
>         __u32   wolopts;
>         __u8    sopass[SOPASS_MAX];	// 6, actually
> };
> is not going to *have* padding.  Not on anything even remotely sane.
> If array of 6 char as member of a struct requires 64bit alignment on some
> architecture, I would really like some of what the designers of that ABI
> must have been smoking.

try this on x86-64

$ pahole -C ethtool_wolinfo vmlinux
struct ethtool_wolinfo {
	__u32                      cmd;                  /*     0     4 */
	__u32                      supported;            /*     4     4 */
	__u32                      wolopts;              /*     8     4 */
	__u8                       sopass[6];            /*    12     6 */

	/* size: 20, cachelines: 1, members: 4 */
	/* padding: 2 */
	/* last cacheline: 20 bytes */
};
