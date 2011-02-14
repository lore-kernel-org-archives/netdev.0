From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter is not a filesystem
Date: Mon, 14 Feb 2011 18:34:10 +0100
Message-ID: <4D596792.40204@trash.net>
References: <bug-28862-10286@https.bugzilla.kernel.org/> <20110210141119.56d789fc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110210141119.56d789fc.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 10.02.2011 23:11, schrieb Andrew Morton:
> On Thu, 10 Feb 2011 21:55:26 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=28862
>>
>>            Summary: /proc/net/ip_conntrack: no space left on device
>>                     systematically
> 
> This is why I'm forever nagging people to not just grab some errno
> because its name happens to sound similar to the error you just detected.
> 
> Yes, it superficially seems nice and logical for netfilter to use
> ENOSPC when it runs out of space.  But when that error code propagates
> up to the user, they see "no space left on device" and will then run
> "df" and wonder what the hell happened to their computer.
> 

In this case this seems to be a simple bug, the seq_file callbacks
want to indicate that the current buffer is full, using an incorrect
code. I'm not sure why ENOSPC is used, this probably has never worked
(and strangely nobody seems to have noticed).

This bug is probably present in more parts of netfilter, I'll do an
audit and fix up all similar problems.
