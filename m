From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/2] bridge: mdb: add support for extended
 attributes
Date: Thu, 18 Feb 2016 21:51:26 +0100
Message-ID: <56C62ECE.6000900@cumulusnetworks.com>
References: <1455623214-2951-1-git-send-email-razor@blackwall.org>
 <20160218.153740.101157132273397459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>, razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38310 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947555AbcBRUv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:51:29 -0500
Received: by mail-wm0-f48.google.com with SMTP id a4so43265996wme.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 12:51:28 -0800 (PST)
In-Reply-To: <20160218.153740.101157132273397459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2016 09:37 PM, David Miller wrote:
> From: Nikolay Aleksandrov <razor@blackwall.org>
> Date: Tue, 16 Feb 2016 12:46:52 +0100
> 
>> Note that the reason we can't simply add an attribute after
>> MDBA_MDB_ENTRY_INFO is that current users (e.g. iproute2) walk over
>> the attribute list directly without checking for the attribute type.
> 
> Honestly that sounds like a bug in iproute2 to me...
> 

I agree, but changing this in the kernel would make older iproute2 versions
incompatible with newer kernels, possibly outputting garbage from the additional
attributes, besides we still will have to turn MDBA_MDB_ENTRY_INFO into a nested
attribute and insert the struct with a header as that's the per-mdb entry attribute
currently.

Alternatively I have a version that uses a request flag in the dump request and
sends back an alternative/"extended" version of the mdbs where every field is
a netlink attribute and is extensible, thus keeping the old format in place
and offering extended attribute support to anyone who requests it.

I just thought this version is a middle ground between the two solutions and
still doesn't break user-space while being extensible.

There're no more holes in the mdb entry struct to reuse.. :-)

Cheers,
 Nik
