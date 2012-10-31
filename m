From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: vlan tagged packets and libpcap breakage
Date: Wed, 31 Oct 2012 15:35:27 -0700
Message-ID: <CAOxq_8O8Vkm5Napp_h6HVj6C=EH2gd_PQJJ1N5d_VQZrRZFYNQ@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org,
	Michael Richardson <mcr@sandelman.ca>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
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

On Wed, Oct 31, 2012 at 3:20 PM, Guy Harris <guy@alum.mit.edu> wrote:
>
> On Oct 31, 2012, at 2:50 PM, Ani Sinha <ani@aristanetworks.com> wrote:
>
>> pcap files that already have the tags reinsrted should work with
>> current filter code. However for live traffic, one has to get the tags
>> from CMSG() and then reinsert it back to the packet for the current
>> filter to work.
>
> *Somebody* has to do that, at least to packets that pass the filter,


yes but if the packet is passed to the filter within libpcap (when we
are not using the kernel filter) before the reinsertion, then the
filter has to be taught to look into the metadata for tag information
and not in the packet itself.

before they're handed to a libpcap-based application, for programs
that expect to see packets as they arrived from/were transmitted to
the wire to work.
>
> I.e., the tags *should* be reinserted by libpcap, and, as I understand it, that's what the
>
>         #if defined(HAVE_PACKET_AUXDATA) && defined(HAVE_LINUX_TPACKET_AUXDATA_TP_VLAN_TCI)
>                 ...
>         #endif
>
> blocks of code in pcap-linux.c in libpcap are doing.

yes, I agree.
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
