From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: help???  trying to trace code path of outgoing udp packet
Date: Fri, 22 Aug 2003 11:23:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F46356A.804@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm trying to figure out the code path taken by an outgoing udp packet, 
and I'm having a bit of trouble figuring out which functions are called 
by which function pointers.  The path that I have so far is this:

udp_sendmsg          udp.c
ip_build_xmit        ip_output.c
output_maybe_reroute ip_output.c   skb->dst->output
ip_output            ip_output.c
ip_finish_output     ip_output.c
ip_finish_output2    ip_output.c   dst->neighbour->output

Is this correct?  Where does it go from here and how does it eventually 
end up in the driver?

In the case in question, the network device is the tulip chip and 
traffic shaping is not enabled, but we do have advanced routing turned on.

Thanks,

Chris


-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
