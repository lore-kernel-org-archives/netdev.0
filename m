From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Fwd: [Bug 5644] New: NFS v3 TCP 3-way handshake incorrect,
 iptables blocks access]
Date: Tue, 29 Nov 2005 23:32:45 +0100
Message-ID: <438CD70D.3030305@trash.net>
References: <20051123.144419.16922351.davem@davemloft.net>
	<20051124140827.GH31478@sunbeam.de.gnumonks.org>
	<20051124144940.GV25399@suse.de>
	<Pine.LNX.4.58.0511250937560.22835@blackhole.kfki.hu>
	<Pine.LNX.4.58.0511291135430.31216@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Olaf Kirch <okir@suse.de>, Harald Welte <laforge@netfilter.org>,
	netfilter-devel@lists.netfilter.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.58.0511291135430.31216@blackhole.kfki.hu>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Jozsef Kadlecsik wrote:
> Mounting NFS file systems after a (warm) reboot could take a long time if
> firewalling and connection tracking was enabled.
> 
> The reason is that the NFS clients tends to use the same ports (800 and
> counting down). Now on reboot, the server would still have a TCB for an
> existing TCP connection client:800 -> server:2049. The client sends a
> SYN from port 800 to server:2049, which elicits an ACK from the server.
> The firewall on the client drops the ACK because (from its point of
> view) the connection is still in half-open state, and it expects to see
> a SYNACK.
> 
> The client will eventually time out after several minutes.
> 
> The following patch corrects this, by accepting ACKs on half open connections
> as well.

Thanks Jozsef, I'll pass it on to Dave tommorrow.
