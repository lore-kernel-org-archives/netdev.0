From: Eric Lammerts <eric-madwifi-devel@lammerts.org>
Subject: problems with 2.6.12
Date: Fri, 01 Jul 2005 11:35:00 -0400
Message-ID: <42C562A4.9070501__15977.6408029304$1120232169$gmane$org@lammerts.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: madwifi-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello all,
I was having problems with 2.6.12 + madwifi in master mode. No packets were 
going out. With tcpdump I see DHCP requests coming in, with strace I see the 
dhcp daemon sending replies out, but they don't show up in tcpdump.

It's caused by this change:
http://oss.sgi.com/projects/netdev/archive/2005-05/msg00109.html

which btw also causes problems for other people:
http://marc.theaimsgroup.com/?l=linux-kernel&m=111853727810345&w=2

Madwifi doesn't call netif_carrier_on() in master mode, so Linux drops all 
packets. When I remove the dev_deactivate() line, it works fine again.

Should we fix madwifi or the kernel?

Eric
