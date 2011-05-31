From: Josh Lehan <krellan@krellan.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Mon, 30 May 2011 21:12:00 -0700
Message-ID: <4DE46A90.6080004@krellan.com>
References: <4DE44218.4070306@krellan.com> <4DE460E1.5020103@ripnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Josh Lehan <linux@krellan.com>, netdev@vger.kernel.org
To: "Marcus D. Leech" <mleech@ripnet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server4.hostdango.com ([70.86.37.74]:57215 "EHLO
	server4.hostdango.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab1EaFD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 01:03:29 -0400
In-Reply-To: <4DE460E1.5020103@ripnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2011 08:30 PM, Marcus D. Leech wrote:
> This sounds like you want UDP, not TCP.
> 
> Unless I'm misunderstanding what you want, you want a protocol that has
> a different "contract"
>   than TCP.  Doing what you want basically requires breaking TCP.  That
> isn't going to happen.

Thanks.  This wouldn't break the TCP protocol on the wire, though.
Instead, it would merely provide a way for a userspace application to
"peek" at the arrived data that's behind the missing packet.  There's
already an ioctl() to peek at unread data, but it considers the missing
packet to be a barrier, and will not allow the application to see beyond it.

The reason for TCP is for maximum compatibility with firewalls, proxies,
and all the other annoyances of the modern commercialized Internet.
Using UDP would indeed solve this problem, but defeat the point of being
compatible.  Using other exotic protocols such as SCTP or DCCP is a
nonstarter.

Josh Lehan
