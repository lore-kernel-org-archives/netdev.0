From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible ip_defrag DoS ?
Date: Sun, 16 Feb 2003 21:26:04 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <3E4FF3DC.7090408@trash.net>
References: <20030215232635.25928.78900.Mailman@kashyyyk> <15950.60635.389199.836425@isis.cs3-inc.com> <3E4F0881.70302@trash.net> <15951.10496.914173.716313@isis.cs3-inc.com> <3E4F8660.5020409@trash.net> <20030216201154.GA30787@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Don Cohen <don-netf@isis.cs3-inc.com>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030216201154.GA30787@sunbeam.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Harald Welte wrote:

>On Sun, Feb 16, 2003 at 01:38:56PM +0100, Patrick McHardy wrote:
>
>  
>
>>inerestingly, it seems linux defragmentation is vulnerable to dos attack.
>>the evictor (called before defragmentation) just kills the oldest entry
>>of each hash slot, starting with 0 until memory is below
>>sysctl_ipfrag_low_thresh. by sending enough fragments 
>>(>sysctl_ipfrag_high_thresh) which hash to the highest bucket you can
>>stop reassembly of valid packets.
>>    
>>
>
>I'm forwarding this (from netfilter-devel) to the linux networking
>developers at netdev@oss.sgi.com.  If your assumption is valid, they
>might want to have a look at this...
>
>thanks.
>
>
>  
>
Hi Harald, it seems this was not (entirely) correct, the evictor only 
kills the last
member of each hash slot and then moves on. still, assuming the hash 
function is good
there is a good chance we can disturb reassembly noticeable.

Patrick
