From: Nick Palmer <nick@sluggardy.net>
Subject: Re: select implementation not POSIX compliant?
Date: Fri, 13 Aug 2004 13:13:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411D20F2.3030101@sluggardy.net>
References: <20040811194018.GA3971@steel.home> <1092256397.512046f64c822@system.cs.fsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Riesen <fork0@users.sourceforge.net>,
        linux-kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: khandelw@cs.fsu.edu
In-Reply-To: <1092256397.512046f64c822@system.cs.fsu.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

khandelw@cs.fsu.edu wrote:
 > select should work for any type of socket. Its based on the type of file
 > descriptor not whether it is stream/dgram.

Agreed, but as Alex Riesen has shown with his test case, the behavior
differs based on the type of socket. This doesn't seem quite right, but
was not my original point.

 > so why should recvmsg return error???? upon closing the socket in 
other thread?
 > wouldn't the socket linger around for some time...

Only if SO_LINGER is on, and then only for the linger time. I would
expect recvmsg to set errno to EINTR or EINVAL indicating that the recv
message was interrupted or is no longer valid since the socket has
closed. This is not the case. Instead it returns 0, and doesn't set errno.

-Nick
