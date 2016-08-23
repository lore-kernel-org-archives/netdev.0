From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 21:09:41 +0100
Message-ID: <20160823200941.GB2356@ZenIV.linux.org.uk>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
 <20160823.094029.1244944495918162255.davem@davemloft.net>
 <1471973727.13300.162.camel@decadent.org.uk>
 <20160823.112406.549221808236512285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: ben@decadent.org.uk, luis.henriques@canonical.com,
        avijitnsec@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160823.112406.549221808236512285.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 23, 2016 at 11:24:06AM -0700, David Miller wrote:

> > On some versions and architectures.  Can you guarantee that you will
> > notice when an exception appears?
> 
> Again, show me the assembler output exhibiting the lack of
> initialization, for this specific structure and situation.
> 
> That's all that I'm asking.

... and then we can file a bug report against the sodding compiler.  Note
that
struct ethtool_wolinfo {
        __u32   cmd;
        __u32   supported;
        __u32   wolopts;
        __u8    sopass[SOPASS_MAX];	// 6, actually
};
is not going to *have* padding.  Not on anything even remotely sane.
If array of 6 char as member of a struct requires 64bit alignment on some
architecture, I would really like some of what the designers of that ABI
must have been smoking.

Initializer might be allowed to leave padding uninitialized.  But all fields
_must_ be initialized, the missing initializers treated exactly as they
would've been for a static-duration object (C99 6.7.8p19).  And that is
going to cover everything in that sucker.  It's not a function of compiler -
only of C ABI on given target.
