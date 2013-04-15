From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 7/7] xen-netback: don't disconnect frontend when
 seeing oversize packet
Date: Mon, 15 Apr 2013 13:36:51 -0400 (EDT)
Message-ID: <20130415.133651.1119146088951084967.davem@davemloft.net>
References: <20130415145320.GE17602@zion.uk.xensource.com>
	<1366039489.8399.83.camel@zakaz.uk.xensource.com>
	<20130415153038.GI17602@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, wdauchy@gmail.com, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, annie.li@oracle.com,
	konrad.wilk@oracle.com, jbeulich@suse.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756335Ab3DORgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:36:54 -0400
In-Reply-To: <20130415153038.GI17602@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 15 Apr 2013 16:30:38 +0100

> On Mon, Apr 15, 2013 at 04:24:49PM +0100, Ian Campbell wrote:
>> On Mon, 2013-04-15 at 15:53 +0100, Wei Liu wrote:
>> > On Mon, Apr 15, 2013 at 10:03:25AM +0100, Ian Campbell wrote:
>> > > On Fri, 2013-04-12 at 18:17 +0100, William Dauchy wrote:
>> > > > On Fri, Apr 12, 2013 at 4:24 PM, Wei Liu <wei.liu2@citrix.com> wrote:
>> > > > > Some frontend drivers are sending packets > 64 KiB in length. This length
>> > > > > overflows the length field in the first slot making the following slots have
>> > > > > an invalid length.
>> > > > >
>> > > > > Turn this error back into a non-fatal error by dropping the packet. To avoid
>> > > > > having the following slots having fatal errors, consume all slots in the
>> > > > > packet.
>> > > > >
>> > > > > This does not reopen the security hole in XSA-39 as if the packet as an
>> > > > > invalid number of slots it will still hit fatal error case.
>> > > > >
>> > > > > Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>> > > > > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>> > > > 
>> > > > Maybe this should be tagged for stable? Maybe part of patch 6/7 as
>> > > > well. I had to remove the part which was disabling the device because
>> > > > of issues encountered in stable tree.
>> > > 
>> > > AFAICT the majority of this series (as well as perhaps some of Wei's
>> > > earlier fixes) should be candidates for any stable tree which received
>> > > the XSA-39 security fixes. Wei -- could you enumerate which patches are
>> > > required to fixup the XSA-39 regressions?
>> > > 
>> > 
>> > Are mechinical fixes such as removing redudent variables / changing log
>> > messages candidates for stable? 1-4 are such kind of fixes.
>> 
>> #4 looks like meat to me too?
>> 
> 
> Not really. DaveM applied first 3 and later I discoverd there was a log
> message which should have been changed in 2. So I wrote a incremental
> patch on top of 2 to fix that.

Please don't do this, it is so confusing.

When I've applied some of your patches, don't repost them, only post the
new patches which are not yet in my tree.

All development and patches occurs relative to my tree, so by reposting
patches already applied you make for confusion and more work on my part.
