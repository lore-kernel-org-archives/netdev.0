From: Ben Greear <greearb@candelatech.com>
Subject: FD_CLOEXEC doesn't take affect through a system("foo") call??
Date: Sun, 30 Jan 2005 22:39:14 -0800
Message-ID: <41FDD292.4070202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I found a funny thing in the 2.6.9 kernel.  Not sure if it only
happens here, or if it's even a bug, but it was unexpected to me at least...

I have a server that opens a listening socket, and sets the FD_CLOEXEC
bit, among other things.  Sometime later, it creates a pppd.bash file
that just starts pppd in the background. From my main process, I
execute the pppd.bash script with the system() command.

My expectation is that pppd would be spawned and that it would NOT
be also listening on the socket that my main server is using.  However,
that is not the case:  The pppd process has that socket and the rest of
the sockets & file-descriptos from the main process open.

I can work around this by explicitly forking, closing all FDs > 2, and
then running the system call, but is what I am seeing expected behaviour?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
