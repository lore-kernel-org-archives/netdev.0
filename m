From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 15:03:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99F17D.10802@nortelnetworks.com>
References: <Pine.GSO.4.30.0210011433300.18461-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
 >
 > On Tue, 1 Oct 2002, Chris Friesen wrote:
 >
 >> to be silently dropped by the kernel because userspace is sending
 >> faster than they can get onto the wire during that tight loop.

 > So what happens when you find packets being dropped? AFAIK, a
 > dropped voice packet is as good as dead whether local or remote.

We do have some leeway in terms of latency, and delayed leaving the box
is not the same as dropped.

We know that call processing messaging can only ever go out one ethernet
interface at a time, and we know that the call agent is guaranteed 90% 
of the userspace cpu time (scheduler changes).  We certify the box for a 
certain engineered throughput, so we know the average packets/sec value. 
We also have total knowledge/control over the other apps running on the 
box in question.

So really all I'm protecting against is from one single userspace app 
generating packets faster than the network can keep up.  As long as I 
get EAGAIN/EWOULDBLOCK/ENOBUFS on my non-blocking socket then I'll just 
try again until it succeeds or I get a more serious error.  So far this 
seems to be working nicely in 2.2, but we're just in the middle of a 
switch to 2.4 for the new release and I want to make sure I've got a 
handle on things.

Thanks for your help,

Chris

PS. I realize that this design is simplistic, but we are severely 
constrained by the legacy app running on the emulator.
