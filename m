From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: [BUG]:   problem when shutting down ppp connection since 2.5.70
Date: Thu, 03 Jul 2003 01:17:09 -0400
Sender: linux-ppp-owner@vger.kernel.org
Message-ID: <3F03BC55.6050506@nortelnetworks.com>
References: <3EFFA1EA.7090502@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-ppp@vger.kernel.org,
	shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <linux-ppp-owner@vger.kernel.org>
To: paulus@samba.org
List-Id: netdev.vger.kernel.org


Well, I've upgraded to the latest 2.5.74 kernel and pppd version 2.4.2b3 
(still using the rp-pppoe userspace software though).

Per Stephen's suggestion I also tried removing the ip address and 
bringing down the ppp link before shuttind down the adsl connection.

Makes no difference.

If I start a dsl connection at system init and then as soon as I get a 
login prompt I shut the connection down, I get the following log:

Jul  3 00:59:26 doug adsl-stop: Killing pppd
Jul  3 00:59:26 doug pppd[779]: Terminating on signal 15.
Jul  3 00:59:26 doug adsl-stop: Killing adsl-connect
Jul  3 00:59:26 doug pppd[779]: Connection terminated.
Jul  3 00:59:26 doug pppd[779]: Connect time 1.5 minutes.
Jul  3 00:59:26 doug pppd[779]: Sent 978 bytes, received 588 bytes.
Jul  3 00:59:29 doug pppoe[781]: Session 511 terminated -- received PADT 
from peer
Jul  3 00:59:29 doug pppoe[781]: Sent PADT
Jul  3 00:59:36 doug kernel: unregister_netdevice: waiting for ppp0 to 
become free. Usage count = 1
Jul  3 01:00:16 doug last message repeated 4 times


If I start the connection up manually after I'm booted, I get the following:

Jul  3 00:03:06 doug adsl-stop: Killing pppd
Jul  3 00:03:06 doug pppd[1763]: Terminating on signal 15.
Jul  3 00:03:06 doug adsl-stop: Killing adsl-connect
Jul  3 00:03:06 doug pppd[1763]: Connection terminated.
Jul  3 00:03:06 doug pppd[1763]: Connect time 0.4 minutes.
Jul  3 00:03:06 doug pppd[1763]: Sent 64 bytes, received 70 bytes.
Jul  3 00:03:06 doug pppoe[1769]: read (asyncReadFromPPP): Session 6990: 
Input/output error
Jul  3 00:03:06 doug pppoe[1769]: Sent PADT
Jul  3 00:03:06 doug pppd[1763]: Exit.


The main difference I see is that in the success case we don't seem to 
be receiving a PADT message, but rather we get an error in asyncReadFromPPP.

Any ideas where to look?  For those on the netdev list who have just 
tuned in, this started happening with 2.5.70.

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com

