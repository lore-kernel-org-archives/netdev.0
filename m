From: Christian Schmid <webmaster@rapidforum.com>
Subject: Still bug-hunting
Date: Sat, 05 Mar 2005 18:57:00 +0100
Message-ID: <4229F2EC.8090103@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I have found out that the slow-down issue with many sockets is a memory problem now. Not that I do 
not have enough but the vm isnt able to reclaim fast-enough. Problem temporarily solved by setting 
lower_zone_protection to 1024. Still I wonder why /proc/net/sockstat shows this:

sockets: used 1637
TCP: inuse 1761 orphan 179 tw 3743 alloc 1761 mem 54224

The send-buffer is set to 128 and the rcv-buffer to 16 so theoretically it should be 1637*144=235728 
so I assume the buffers are allocated dynamically when they are really needed... I suppose the 
slow-down wouldnt appear if the buffers are allocated statically. Is there any way to check this?

Chris
