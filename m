From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: netlink hooks for 2.5.59 (6/8)
Date: Thu, 30 Jan 2003 15:19:47 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030130.151947.48545419.davem@redhat.com>
References: <Pine.LNX.4.44.0301311001440.31382-100000@blackbird.intercode.com.au>
	<Pine.LNX.4.44.0301311006230.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Pine.LNX.4.44.0301311006230.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This one is not acceptable, you're adding a function call to
every netlink SKB receive even in the case where security
is disabled.

Capability testing is a very simple bit test, there is no
justification for calling these cap_netlink_{send,recv}() things
externally for such a simple operation when security is disabled.

It is things like this that make me still totally hate the networking
security changes.  It is like a virus that is spreading throughout the
entire tree.  It is a bunch of strange tests that have to be
maintained which do external calls to modules that are not even in the
source tree so I can't even see how the callbacks are used (no, the
fact that there is documentation of the callback doesn't change this
issue, and no I'm not going to some site to download a bunch of
security modules everytime I need to make changes in these areas).

Frankly, while I'm very happy about the fixup of the security
overhead, these changes are still way too invasive.  This stuff
is garbage.
