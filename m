From: Nick Palmer <nick@sluggardy.net>
Subject: Re: select implementation not POSIX compliant?
Date: Fri, 13 Aug 2004 13:12:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411D20C8.1080400@sluggardy.net>
References: <20040811194018.GA3971@steel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex Riesen <fork0@users.sourceforge.net>
In-Reply-To: <20040811194018.GA3971@steel.home>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex Riesen wrote:
> On linux-kernel, Nick Palmer wrote:
>>The application
>>expects that a close call on a socket that another thread is
>>blocking in select and/or recvmsg on will cause select and/or
>>recvmsg to return with an error. Linux does not seem to do this.
> 
> 
> It works always for stream sockets and does not at all (even with
> shutdown, even using poll(2) or read(2) instead of select) for dgram
> sockets.
> 
> What domain (inet, local) are your sockets in?

inet.

> What type (stream, dgram)?

We use both, though the breakage I was trying to fix was with a dgram 
socket.

You are correct that it does not work for dgram sockets at all! I had 
not noticed the difference between the two in the test case I wrote, 
since I hadn't tested streams. Thanks for pointing that out. Note that 
shutdown will cause a dgram socket to exit from a recv* call though, as 
this is the workaround I am using right now. On Solaris close will do 
the job. However when the recv from ends it returns 0, but does not set 
errno, which indicates that there may be more data that can be retrieved 
with another call to recv. On Solaris both shutdown and close cause 
errno to be set.

There is no way then to cause a select on a dgram socket to break out at 
all short of kludging some dgram packet transmission to cause it to happen.

Yech!

Thanks for looking into the issue more,
-Nick
