From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 10:26:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99B07B.7050901@nortelnetworks.com>
References: <200210011353.RAA19504@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.CA>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

> That was tried and failed miserably ages ago. Applications become
> insane when getting this error from logging tons of useless messages
> to abort()ing and cpu hogging. From the other hand silent reaction
> to loss is almost exactly desired behaviour in presence of congestion
> in the most of cases.
> 
> I have no idea, why that OSes work. Probably, they are so great that
> never lose packets. We do. 

One of the principles of software design that I was taught was the 
principle of least surprise.

If I'm looping on a sendto() with a blocking socket, I would expect the 
syscall to block until the packet has been handed off to the device 
driver.  This may mean blocking until local congestion backs off.

If I'm using non-blocking IO and there is local congestion, I would 
expect to get ENOBUFS or maybe EAGAIN/EWOULDBLOCK.

The way we do it now means that we can chew up massive amounts of cpu 
creating packets in userspace and throwing them away in the kernel, with 
no way of knowing from userspace that it is happening.  This just 
doesn't seem like the right thing to do.

Chris
