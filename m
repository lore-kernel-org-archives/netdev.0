From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 08 Jul 2004 14:33:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40ED936F.9000905@nortelnetworks.com>
References: <20040708170705.GA6895@apps.cwi.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Michael T Kerrisk <mtk-lists@gmx.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andries Brouwer <Andries.Brouwer@cwi.nl>
In-Reply-To: <20040708170705.GA6895@apps.cwi.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andries Brouwer wrote:
> Can you find the man-pages-1.67 package and construct a concrete patch?
> 
> (Don't know precisely what you want to do. The above gives a filename
> recv.man, which would be recv.2 in my sources. But there is no MSG_NOSIGNAL
> in recv.2, only in send.2. The fragment of text that you give occurs
> already in recv.2.)

Sorry, the filenames have no meaning since I wasn't working from the package, 
but from the output of the "man" command.

Working from the webpage at:

http://homepages.cwi.nl/~aeb/linux/man2html/man2/recv.2.html

There is mention of MSG_DONTWAIT when discussing the "msg_flags" field in 
"struct msghdr".  It contains exactly the text proposed.  However, the msg_flags 
field is set on *return* of the call.  Every other flag discussed there 
"indicates" something.  The blurb for MSG_DONTWAIT says that it "enables" a 
behaviour, which doesn't make sense for a field set on call return.

There is no mention of MSG_DONTWAIT when discussing the "flags" parameter of the 
recv/recvfrom/recvmsg call.

Generally, I want to move the current blob from the "msg_flags" area to the 
"flags" area, and then add a different discussion for "msg_flags" if appropriate 
(I'm not sure about that part).

Do you still want me to generate an actual patch against man-pages-1.67, or is 
that description enough?

Chris
