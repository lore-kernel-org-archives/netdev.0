From: Bill Fenner <fenner@gmail.com>
Subject: Re: PROBLEM: Software injected vlan tagged
 packets are unable to be identified using recent BPF modifications
Date: Thu, 10 Jan 2013 15:37:46 -0500
Message-ID: <CAF4SogagSH_NdT3Shr-_0D9TQNv8QP6viJaY=4PMv5rYMSgX6Q@mail.gmail.com>
References: <CAOUgPvQP2RrngPPf=hYxpPdGSQ4L-Db0T-BMDwVg6iy8LTAu=Q@mail.gmail.com>
	<CAOxq_8MJZtFYHmsqQdZ+DSDuHjgkQYrHG2rPt32m6TRTV-ZS9A@mail.gmail.com>
	<CAOUgPvQhyC5LTVAZeeRd3N-Jdpe+cHK4LQWZUB-qTKT_og7dSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>,
	edumazet <edumazet@google.com>,
	tcpdump-workers <tcpdump-workers@lists.tcpdump.org>,
	David Miller <davem@davemloft.net>
To: Paul Pearce <pearce@cs.berkeley.edu>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <CAOUgPvQhyC5LTVAZeeRd3N-Jdpe+cHK4LQWZUB-qTKT_og7dSw@mail.gmail.com>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Sender: tcpdump-workers-bounces@lists.tcpdump.org
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 7, 2013 at 10:04 PM, Paul Pearce <pearce@cs.berkeley.edu> wrote:
> However, raw vlan tagged packets that are *injected* into the
> interface using libpcap's pcap_inject() (which is just a fancy wrapper
> for the send() syscall) are not identified by filters using the recent
> BPF modifications.
>
> The bug manifests itself if you attempt to use the new BPF
> modifications to filter vlan tagged packets on a live interface. All
> packets from the medium show up, but all injected packets are dropped.

Given that the vlan tag metadata is supplied to userland with
PACKET_AUXDATA, does the symmetrical sendmsg() with PACKET_AUXDATA
work to put the vlan info in the metadata?  I.e., this would require
modifying pcap_inject() to parse the packet and extract the VLAN tag
info into a struct tpacket_auxdata, but obviously you could write a
little test program to test the underlying PF_PACKET socket behavior.

Even if it doesn't currently work, I think this may be a more
acceptable change ("provide a way to set PACKET_AUXDATA using
sendmsg") than having the packet send code munge/parse the vlan tag on
output.

  Bill
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
