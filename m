From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Tue, 15 Feb 2005 15:23:54 -0800
Message-ID: <20050215152354.46a08d77.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<20050211150420.74737b2e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hubert.tonneau@fullpliant.org, romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru,
        niv@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050211150420.74737b2e@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 15:04:20 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Still not setting Push sufficiently to keep MacOSX happy.
 ...
> 13:40:35.034930 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: P 1179:1230(51) ack 133132 win 65535 
> 13:40:35.035304 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 133132:134580(1448) ack 1230 win 1460 
> 13:40:35.035312 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 134580:136028(1448) ack 1230 win 1460
> 
> Big gap... because of missing P
> 
> 13:40:35.219175 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: . ack 136028 win 63716 

I am starting to understand Darwin's logic.  If header prediction fast path
is hit, ACK is always delayed when delack sysctl is enabled.

One way to miss fast path is for PSH to be set.

This will make ACK not get delayed if ACK is pending already.

At least that is how it looks, and it makes sense given this trace.

How mind boggling a heuristic.  I bet it works by accident rather
than intention and purposeful design.
