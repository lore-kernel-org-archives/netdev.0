From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 22:25:45 +0100
Message-ID: <20160823212545.GC2356@ZenIV.linux.org.uk>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
 <20160823.094029.1244944495918162255.davem@davemloft.net>
 <1471973727.13300.162.camel@decadent.org.uk>
 <20160823.112406.549221808236512285.davem@davemloft.net>
 <20160823200941.GB2356@ZenIV.linux.org.uk>
 <1471984445.3746.129.camel@perches.com>
 <20160823204933.GA14311@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        ben@decadent.org.uk, luis.henriques@canonical.com,
        avijitnsec@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160823204933.GA14311@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 23, 2016 at 04:49:33PM -0400, Lennart Sorensen wrote:
> That would be padding after the structure elements.
> 
> I think what was meant is that it won't add padding in the middle of the
> structure due to alignment, ie it isn't doing:
> 
> struct ethtool_wolinfo {
> 	__u32                      cmd;                  /*     0     4 */
> 	__u32                      supported;            /*     4     4 */
> 	__u32                      wolopts;              /*     8     4 */
> 	<4 bytes padding here>
> 	__u8                       sopass[6];            /*    16     6 */
> };
> 
> which would have 4 bytes of padding in the middle between wolopts
> and sopass.
> 
> I would not think it is the compilers job to worry about what is after
> your structure elements, since you shouldn't be going there.

Sadly, sizeof is what we use when copying that sucker to userland.  So these
padding bits in the end would've leaked, true enough, and the case is somewhat
weaker.  And any normal architecture will have those, but then any such
architecture will have no more trouble zeroing a 32bit value than 16bit one.
