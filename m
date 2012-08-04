From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Fri, 3 Aug 2012 22:04:02 -0700
Message-ID: <CAEuXFExg2X9r0zE8wUs9Npd7jPUN2WHbyJcnH6eT_23f2DoPjw@mail.gmail.com>
References: <20120727183840.GE17572@p12n.org>
	<26496.1343419205@death.nxdomain>
	<20120801144104.GN17572@p12n.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	jgoerzen@efolder.net
To: Peter Samuelson <psamuelson@efolder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:37291 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2HDFEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 01:04:04 -0400
Received: by yenl2 with SMTP id l2so1524627yen.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 22:04:02 -0700 (PDT)
In-Reply-To: <20120801144104.GN17572@p12n.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 1, 2012 at 7:41 AM, Peter Samuelson <psamuelson@efolder.net> wrote:
>
>   [Peter Samuelson]
>> >    ixgbe [10 Gbit port] -- bonding [802.3ad] -- bridge -- KVM guest
>> >
>> >It all works, except that with some flows in the KVM guest - I
>> >can reproduce using smbclient - transfers keep stalling, such that I'm
>> >averaging well under 1 MB/s.  Should be more like 100 MB/s.
>> >
>> >Oddly, this only occurs when both the 802.3ad and KVM are used:

is it because offloads are enabled?  I had to disable several of them
to get my virtual machines to work on both igb and ixgbe interfaces, I
haven't gone any further to isolate why.

try
# ethtool -K ethx tso off gso off lro off
