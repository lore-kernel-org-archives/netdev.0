From: John Haller <jhaller@lucent.com>
Subject: SO_REUSEADDR, restarting servers, and security patches
Date: Thu, 01 Jul 2004 23:39:53 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E4E719.6000508@lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In October 2002, Yoshifuji Hideaki introduced a
patch that prevents completely any duplication
of <local-addr, local-port, remote-addr, remote-port>,
even when SO_REUSEADDR is set, preventing port
stealing denial-of-service attacks.  This also
has the side effect of not allowing a server to
be immediately restarted after being stopped,
because of the sockets that remain in the TCP_TIME_WAIT
state.

Would security be negatively impacted by relaxing
the restrictions introduced by the above patch
to allow a bind to a TCP port only if all existing
references to that TCP port were in the TCP_TIME_WAIT
state, and both the listening port and all of the
TCP_TIME_WAIT sockets had the SO_REUSEADDR flag set?
This relaxation would only help in the case of
servers where the listener and connected sockets
are all stopped at the same time, and not loosely
connect servers where the connected sockets are
handled in a separate process from the listener.

I don't want to use SO_REUSEPORT for two reasons.
The first is that SO_REUSEPORT allows binding
the same address twice for active sockets.  The
second is that SO_REUSEPORT is not commonly enabled.

The top message regarding the patch is located here:
http://oss.sgi.com/projects/netdev/archive/2002-10/msg00035.html
-- 
John Haller
