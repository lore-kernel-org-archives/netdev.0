From: Steve Modica <modica@sgi.com>
Subject: Zero copy transmit
Date: Tue, 29 Apr 2003 13:44:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EAEC7FF.4040504@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

We are doing some experiementing with Altix systems (Itanium II with
NUMA) and we're taking a big hit from __copy_user traffic.  We would
like to modify the write, writev, send and sendto interfaces such that
we can avoid the __copy_user call by marking pages copy-on-write (COW)
and handing them off to be transmitted.  Since this requires TLB 
updates, we would only implement this code on platforms that defined 
themselves as capable of fast TLB updates.

There was a lot of concern expressed on the l-k alias about COW being 
difficult to support becaue of the TLB update issues, but NUMA systems 
have to be especially quick at TLB updates, so it's something we want to 
take advantage of.

I'm looking for comments and suggestions as to how we could do this 
without impacting other system types.

Best Regards!
Steve
-- 
Steve Modica
Manager - Networking Drivers Group
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
