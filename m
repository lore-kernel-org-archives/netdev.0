From: Steve Modica <modica@sgi.com>
Subject: Re: variation in thruput w/ change in mtu on gige
Date: Mon, 26 Apr 2004 10:02:07 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408D246F.8090404@sgi.com>
References: <Pine.GSO.4.50.0404261700390.241-100000@revati>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Abhijit Karmarkar <abhijitk@veritas.com>
In-Reply-To: <Pine.GSO.4.50.0404261700390.241-100000@revati>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Probably page size. 4k is one page so those are probably the most efficient IOs. 
There must be some additional handling required to squeeze multiple pages into 
an MTU.  Have you profiled things at all to see what additional code has to run 
in order to handle multiple pages?

Steve

Abhijit Karmarkar wrote:
> Hi,
> 
> i have observed that using jumbo frames (mtu=9000) decreases the thruput
> (i am timing one-way ttcp). trying w/ different mtu's i see 4096 give
> me the best numbers:
> 
> mtu             thruput
> -------------------------------
> 1500 (default)  ~846Mbps
> 4096            ~930Mbps <== highest
> 8192            ~806Mbps
> 9000            ~806Mbps
> 15K             ~680Mbps
> 
> my setup is:
> - 2 nodes connected directly (cross-over cable)
> - each node: 2-way, 2.4G Xeon. 4G RAM., running RHEL3 (2.4.21-4.ELsmp)
> - intel gige (82543GC), e1000 ver. (5.1.11-k1)
>   i think the cards are: 64bit/66Mhz PCI.
> - ipv4.tcp_r/wmem and core.r/wmem_max set sufficiently high (512KB)
> - using ttcp to xfer ~8GB one-way.
> 
> why doesn't my thruput increase with increase in MTU? is it because of
> small number of rx/txdescriptors on 82543GC (max=256?) or something
> else?
> 
> are there any driver parameters that i can tune to get better numbers
> with larger MTUs?
> 
> thanks,
> abhijit
> 


-- 
Steve Modica
work: 651-683-3224
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
