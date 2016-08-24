From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Wed, 24 Aug 2016 22:36:08 +0200
Message-ID: <18517b44-0d3f-3f83-e327-60064c170c5a@stressinduktion.org>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
 <20160823.094029.1244944495918162255.davem@davemloft.net>
 <1471973727.13300.162.camel@decadent.org.uk>
 <20160823.112406.549221808236512285.davem@davemloft.net>
 <20160823200941.GB2356@ZenIV.linux.org.uk>
 <1471984445.3746.129.camel@perches.com>
 <20160823204933.GA14311@csclub.uwaterloo.ca>
 <20160823212545.GC2356@ZenIV.linux.org.uk>
 <20160824140316.GB14309@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        ben@decadent.org.uk, luis.henriques@canonical.com,
        avijitnsec@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
        Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:45868 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755728AbcHXUgO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 16:36:14 -0400
In-Reply-To: <20160824140316.GB14309@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.08.2016 16:03, Lennart Sorensen wrote:
> On Tue, Aug 23, 2016 at 10:25:45PM +0100, Al Viro wrote:
>> Sadly, sizeof is what we use when copying that sucker to userland.  So these
>> padding bits in the end would've leaked, true enough, and the case is somewhat
>> weaker.  And any normal architecture will have those, but then any such
>> architecture will have no more trouble zeroing a 32bit value than 16bit one.
> 
> Hmm, good point.  Too bad I don't see a compiler option of "zero all
> padding in structs".  Certainly generating the code should not really
> be that different.
> 
> I see someone did request it 2 years ago:
> https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63479

I don't think this is sufficient. Basically if you write one field in a
struct after a memset again, the compiler is allowed by the standard to
write padding bytes again, causing them to be undefined.

If we want to go down this route, probably the only option is to add
__attribute__((pack)) those structs to just have no padding at all, thus
breaking uapi.

E.g. the x11 protocol implementation specifies padding bytes in their
binary representation of the wire protocol to limit the leaking:

https://cgit.freedesktop.org/xorg/proto/xproto/tree/Xproto.h

... which would be another option.

Bye,
Hannes
