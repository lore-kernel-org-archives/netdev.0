From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: 06 Dec 2004 06:40:43 -0500
Message-ID: <1102333242.1048.2268.camel@jzny.localdomain>
References: <41B0A5B4.6060108@suse.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <mludvig@suse.cz>
In-Reply-To: <41B0A5B4.6060108@suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think this patch will break more than it fixes. You need to do a lot
more testing to verify it doesnt. Actually you should probably fix whats
being invoked for the ifa messages when PF_UNSPEC is selected to check
that it only flushes v6 addresses when V6 is on and reject when it is
not compiled in.

cheers,
jamal

On Fri, 2004-12-03 at 12:43, Michal Ludvig wrote:
> Hi,
> 
> running 'ip -6 addr flush dev eth0' on a kernel without IPv6 support
> flushes *all* addresses from the interface, even those IPv4 ones,
> because the unsupported protocol is substituted by PF_UNSPEC.
> IMHO it should better return with an error EAFNOSUPPORT.
> 
> Attached patch fixes it. Please apply.
> 
> BTW Credits to Jan Kara <jack@suse.cz> for discovering and analysing
> this bug.
> 
> Michal Ludvig
