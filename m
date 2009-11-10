From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Tue, 10 Nov 2009 15:06:25 -0600
Message-ID: <4AF9D5D1.9040501@nortel.com>
References: <4AF9A63B.6010101@nortel.com>	 <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>	 <4AF9B2CF.6050305@nortel.com> <1257884799.3044.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:52123 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758159AbZKJVIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 16:08:06 -0500
In-Reply-To: <1257884799.3044.7.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2009 02:26 PM, Trond Myklebust wrote:
> On Tue, 2009-11-10 at 12:37 -0600, Chris Friesen wrote:
>> On 11/10/2009 11:53 AM, Ben Hutchings wrote:
>>> On Tue, 2009-11-10 at 11:43 -0600, Chris Friesen wrote:
>>
>>>> Given that a userspace application can be stopped and restarted at any
>>>> time, and a sunrpc registration can happen at any time, what is the
>>>> expected mechanism to prevent the kernel from allocating a port for use
>>>> by sunrpc that reserved or well-known?
>>>>
>>>> Apparently Redhat and Debian have distro-specific ways of dealing with
>>>> this, but is there a standard solution?  Should there be?
>>>>
>>>> The current setup seems suboptimal.
>>>
>>> I believe both RH and Debian are using the same implementation:
>>> <http://cyberelk.net/tim/software/portreserve/>.
>>
>> That helps with the startup case, but still leaves a possible hole if an
>> app using a fixed port number is restarted at runtime.  During the
>> window where nobody is bound to the port, the kernel could randomly
>> assign it to someone else.
> 
> Just use /proc/sys/sunrpc/{max,min}_resvport interface to restrict the
> range used to a safer one. That's what it is for...

What constitutes a "safer range"?  IANA has ports assigned
intermittently all the way through the default RPC range.  The largest
unassigned range is 922-988 (since 921 is used by lwresd).  If someone
needs more than 66 ports, how are they supposed to handle it?

Chris
