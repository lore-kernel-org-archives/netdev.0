From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [patch 27/28] Introduce U16_MAX and U32_MAX
Date: Tue, 14 Aug 2007 00:33:13 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708140028420.29609@enigma.security.iitk.ac.in>
References: <200708102112.l7ALCA2M009460@imap1.linux-foundation.org>
 <20070810.153819.76325424.davem@davemloft.net>
 <alpine.LFD.0.999.0708132039200.29609@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:57831 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S974241AbXHMSug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 14:50:36 -0400
In-Reply-To: <alpine.LFD.0.999.0708132039200.29609@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 13 Aug 2007, Satyam Sharma wrote:

> Hi David,
> 
> 
> On Fri, 10 Aug 2007, David Miller wrote:
> [...]
> > 1) The reiserfs definition is better, it is _type_ based.
> >    Please use (~(__u16)0) and (~(__u32)0), respectively.
> 
> Hmm, in that case ((__u16)0xffff) and ((__u32)0xffffffff) are probably
> better and clearer -- as that's what u16_max and u32_max are, after all.
> 
> We do require the (~0) thing for the max int/uint/long types, but that's
> because those are types where the number-of-bits is not known when writing
> the macro definition -- but that's not case with u16 and u32, so the
> 0xff... variants are clearer, IMHO.
> 
> 
> > 2) The reiserfs definition is going to define an equivalent
> >    value, so just adding an #undef and still letting reiserfs
> >    override is wrong.  Why put a common define in kernel.h
> >    if other headers still keep their own crufty copy too?
> 
> Because removing the (re-)definition of U32_MAX from in there in
> reiserfs_fs.h will break builds of all userspace users of U32_MAX and
> max_reiserfs_offset(), would it not? I haven't looked at any reiserfs
> userspace tools source code, so possibly none such (that use
> max_reiserfs_offset) exist, but I thought it better to be safe.
> I'll have a look at the reiserfs-utils package, just in case.

I checked with latest reiserfsprogs available from namesys.com and also
reiserfs-utils package available from Fedora, and it appears there are
no users of either U32_MAX or max_reiserfs_offset() in any userspace
reiserfs tools, so we're safe in removing the U32_MAX from
include/linux/reiserfs_fs.h.


Thanks,
Satyam
