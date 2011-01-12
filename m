From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: TCP connections stall when station re-associates.
Date: Tue, 11 Jan 2011 17:02:48 -0800
Message-ID: <4D2CFDB8.3010907@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


We're seeing something funny while testing ath9k and ath5k with
multiple VIFs.  We are using send-to-self routing rules
and have a TCP connection going between two station interfaces
connected to the same AP.  Kernel is ~2.6.37 (wireless-testing from
a few days ago, plus some local patches).  We tried commercial
APs and ath9k/ath5k APs running 2.6.37 kernel and hostap with
similar results.

The problem is that when the stations loose association and
re-associate (and maybe other times as well), the TCP connections
often hang.  I see buffers in the sendq in netstat, and retransmits
on the wire, but it seems to make no progress.

Here's a pair of sockets with one side in the state:

tcp        0   7312 7.7.1.54:33513              7.7.1.56:33514              ESTABLISHED
tcp        0      0 7.7.1.56:33514              7.7.1.54:33513              ESTABLISHED

Here's a brief snippet from the interface with 7.7.1.56 on it:

  51.517954     7.7.1.56 -> 7.7.1.54     TCP 33514 > 33513 [PSH, ACK] Seq=64229 Ack=1 Win=63 Len=12 TSV=8209159 TSER=7621148
  51.521719     7.7.1.54 -> 7.7.1.56     TCP 33513 > 33514 [ACK] Seq=13 Ack=64241 Win=377 Len=0 TSV=8209162 TSER=8209159
  52.279788     7.7.1.54 -> 7.7.1.56     TCP [TCP Retransmission] 33513 > 33514 [PSH, ACK] Seq=1 Ack=64241 Win=377 Len=12 TSV=8209920 TSER=8209159

The TCP connection is trying to run at 9.6kbps, sending 1460 bytes
per 'send' call.

If I start a UDP connection on the same pair of ports it
runs fine, even while the TCP connection is hung.

I am curious if anyone has any suggestions for debugging
this further, for instance, some way to see why the
TCP connection is not making forward progress.

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
