From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Fwd: [Bug 3397] New: Network connections hang going through an
 OpenBSD firewall]
Date: Tue, 14 Sep 2004 14:06:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914140603.4698a9e5@dell_ss3.pdx.osdl.net>
References: <41475BEA.2030803@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vuksan-hoforums@veus.hr, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <41475BEA.2030803@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004 14:00:26 -0700
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Can you reproduce on the latest kernel, please?
> Is the OpenBSD mangling the packet in any way?
> 
> Can anyone tell me if this smells like something
> recently fixed (MTU issues)? Doesn't sound like
> the windowscaling problem but could be related.

OpenBSD pf is easy to configure to break window scaling.
The developer claims its not a bug. Basically stateless
TCP connection tracking will never work, it's a bad idea.

Daniel Hartmeier <daniel@benzedrine.cx> wrote:

> The problem arises when the user creates a complicated ruleset that
> passes the first SYN of a connection without creating a state entry. You
> might argue that this shouldn't be possible, but some forms of stateless
> filtering are being used. The man page warns against this, too.
> 
> In this particular case, the ruleset tells pf to pass the initial SYN
> without creating state (and therefore without any place to note the
> window option and first scale factor). When, later, the SYN+ACK creates
> state, the state just doesn't contain the information to follow the
> scaled windows.
