From: "Christopher Friesen" <cfriesen@nortel.com>
Subject: Re: help with e1000 issue?
Date: Thu, 19 Jan 2006 10:48:01 -0600
Message-ID: <43CFC2C1.2080308@nortel.com>
References: <43CEAA6E.80902@nortel.com> <4807377b0601181316w2ac0fb0dod976e456816331ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0601181316w2ac0fb0dod976e456816331ae@mail.gmail.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> On 1/18/06, Christopher Friesen <cfriesen@nortel.com> wrote:

>>So, somehow we're getting into a state where we can't receive packets,
>>and we're never getting out of that state.

> Are you sure that you're able to transmit and you aren't just handing
> it to the hardware and it never gets out?  tcpdump on a remote machine
> would verify.

I haven't tried the new driver yet, so this is still with the old driver 
(had the hung machine still up from yesterday).

It looks like tx is working--we see the packets on the other machines on 
the network.  I tested unicast and broadcast, and both seem to be working.

I tried a broadcast ping to the whole subnet.  For that one the icmp 
packet goes out, then we see ARPs from everyone on the subnet trying to 
get the MAC address of the machine with eth issues.



On the machine with hung ethernet:

root@172.24.101.12:/root> ping -b 172.25.0.0
WARNING: pinging broadcast address
PING 172.25.0.0 (172.25.0.0) 56(84) bytes of data.
64 bytes from 172.25.101.12: icmp_seq=1 ttl=64 time=0.041 ms
64 bytes from 172.25.101.12: icmp_seq=2 ttl=64 time=0.046 ms


On the other machine:

root@10.102.92.28:/root> tcpdump -n -i bond1 host 172.25.101.12
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on bond1, link-type EN10MB (Ethernet), capture size 96 bytes
01:51:27.275594 IP 172.25.101.12 > 172.25.0.0: icmp 64: echo request seq 1
01:51:27.275748 arp who-has 172.25.101.12 tell 172.25.80.0
01:51:27.275824 arp who-has 172.25.101.12 tell 172.25.101.16
01:51:27.276248 arp who-has 172.25.101.12 tell 172.25.101.13
01:51:27.276373 arp who-has 172.25.101.12 tell 172.25.101.1
01:51:28.275674 arp who-has 172.25.101.12 tell 172.25.101.16
01:51:28.276258 arp who-has 172.25.101.12 tell 172.25.101.1
01:51:28.278017 arp who-has 172.25.101.12 tell 172.25.80.0
01:51:28.278260 IP 172.25.101.12 > 172.25.0.0: icmp 64: echo request seq 2
01:51:28.278388 arp who-has 172.25.101.12 tell 172.25.101.13
01:51:29.275520 arp who-has 172.25.101.12 tell 172.25.101.16
01:51:29.276018 arp who-has 172.25.101.12 tell 172.25.101.1
01:51:29.280032 IP 172.25.101.12 > 172.25.0.0: icmp 64: echo request seq 3
01:51:29.280277 arp who-has 172.25.101.12 tell 172.25.80.0
01:51:29.280524 arp who-has 172.25.101.12 tell 172.25.101.13


Chris




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
