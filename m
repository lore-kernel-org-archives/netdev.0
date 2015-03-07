From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: IPv6 GRE sending to undefined destinations
Date: Sun, 08 Mar 2015 00:01:44 +0100
Message-ID: <54FB8358.6040406@baanhofman.nl>
References: <54F9D70C.7030409@baanhofman.nl> <1425750711.4027.12.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.baanhofman.nl ([92.222.219.102]:42473 "EHLO
	vps.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbbCGXCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 18:02:12 -0500
In-Reply-To: <1425750711.4027.12.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/15 18:51, Ben Hutchings wrote:
>> > With the following patch I am able to make it work, but I'm not sure
>> > about the implications of changing the size of the sll_addr buffer.
> We can't do that as it will break binary compatibility with existing
> applications.  It sounds like there is a need for a new, larger
> structure but I don't know all the compatibility implications of that.
>
I'm not so sure. Existing applications will know the old size, 8 bytes
and will only read and set these 8 bytes.
Newer applications can use 16 bytes. It only messes up when newer
headers are used on an older kernel, not the other way around.

The problem is, with the old size, running multipoint tunnels over IPv6
will not work (at least not without an sll netlink interface overhaul).
The NBMA size and interface seems to work, given that the neighbour list
is updated correctly.

$ ip -6 neigh list
fe80::3 dev gre1 lladdr fc:00:00:00:00:00:00:00:00:00:00:00:00:00:00:03
REACHABLE

I can understand not wanting to break newer userspace/older kernel in
this case, though. Any pointers on how to best approach a clean kernel
interface update to make sll netlink work over IPv6 transport?

-- Wilco
