From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: ack.lrcvtime initialization in Linux 2.6.9
Date: Thu, 11 Nov 2004 23:58:59 +0200
Message-ID: <20041111215859.GC9589@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Networking Mailing List <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

when no data was received during the connection,
tcpi_last_data_recv in struct tcp_info (getsockopt(...TCP_INFO...))
contains garbage value.  for example, one 30-second connection
had tcpi_last_data_recv=133682531.
then I thought maybe I could first check if tcpi_ato==0...
but no, sometimes it's 40000 (TCP_ATO_MIN) when no data was received.

so, I think it would be funnier if tcpi_last_data_recv was 0
(or 4294967295, or...) when no data was received.  right? :)

-- 
