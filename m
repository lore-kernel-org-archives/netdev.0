From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 15:04:20 -0800
Message-ID: <20050211150420.74737b2e@dxpl.pdx.osdl.net>
References: <0525M9211@server5.heliogroup.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, romieu@fr.zoreil.com,
        kuznet@ms2.inr.ac.ru, Nivedita Singhvi<niv@us.ibm.com>,
        Rick Jones
 <rick.jones2@hp.com>, netdev@oss.sgi.com
To: Hubert Tonneau <hubert.tonneau@fullpliant.org>
In-Reply-To: <0525M9211@server5.heliogroup.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 21:55:49 GMT
Hubert Tonneau <hubert.tonneau@fullpliant.org> wrote:

> Sorry, it still does not work, unless I made a mistake:
> Linux 2.6.9 takes 15 seconds to copy 105 MB to Mac OSX
> Linux 2.6.10 with the TCP patch below still takes 325 seconds to do the same.
> 
> You can pick the new tcpdump report, created through:
> tcpdump -i eth1 ip host 10.107.96.230 -w /tmp/dump-2.6.10-tcp2
> at http://fullpliant.org/pliant/browse/file/archive/dump-2.6.10-tcp2.gz

Still not setting Push sufficiently to keep MacOSX happy.

13:40:35.027124 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: P 924:975(51) ack 67344 win 50728 
13:40:35.027186 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: . ack 67344 win 65535 
13:40:35.027328 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: P 975:1026(51) ack 67344 win 65535 
13:40:35.027363 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 67344:68792(1448) ack 1026 win 1460 
13:40:35.027367 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 68792:70240(1448) ack 1026 win 1460 
13:40:35.027370 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 70240:71688(1448) ack 1026 win 1460 
13:40:35.027373 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 71688:73136(1448) ack 1026 win 1460 
13:40:35.027375 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 73136:74584(1448) ack 1026 win 1460 
13:40:35.027378 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 74584:76032(1448) ack 1026 win 1460 
13:40:35.027381 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 76032:77480(1448) ack 1026 win 1460 
13:40:35.027384 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 77480:78928(1448) ack 1026 win 1460 
13:40:35.027387 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 78928:80376(1448) ack 1026 win 1460 
13:40:35.027390 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 80376:81824(1448) ack 1026 win 1460 
13:40:35.027393 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 81824:83272(1448) ack 1026 win 1460 
13:40:35.027397 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: P 83272:83980(708) ack 1026 win 1460 

okay burst with push

13:40:35.034930 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: P 1179:1230(51) ack 133132 win 65535 
13:40:35.035304 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 133132:134580(1448) ack 1230 win 1460 
13:40:35.035312 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 134580:136028(1448) ack 1230 win 1460

Big gap... because of missing P

13:40:35.219175 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: . ack 136028 win 63716 
13:40:35.219193 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 136028:137476(1448) ack 1230 win 1460 
13:40:35.219197 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 137476:138924(1448) ack 1230 win 1460 
13:40:35.419193 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: . ack 138924 win 60820 
13:40:35.419202 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 138924:140372(1448) ack 1230 win 1460 
13:40:35.419205 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 140372:141820(1448) ack 1230 win 1460 
13:40:35.419207 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 141820:143268(1448) ack 1230 win 1460 
