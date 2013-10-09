From: Yuchung Cheng <ycheng@google.com>
Subject: Re: IPv6 kernel warning
Date: Wed, 9 Oct 2013 10:33:04 -0700
Message-ID: <CAK6E8=fZnQXNjO_dh7sALOfsa=BL7qKzzZkzQrRtX3k9ehBZPA@mail.gmail.com>
References: <20130920131153.GF12758@n2100.arm.linux.org.uk>
 <20130920160830.GA4241@marquez.int.rhx> <CAK6E8=eNFG0fic+NYeQBjEoUQMeZKSAT3LU0JSQyE-4i_cDaZQ@mail.gmail.com>
 <alpine.DEB.2.02.1310071111240.17658@dtop> <CAK6E8=czoej81t=-J=gjjyQiGVbZ0qiNKBbeRVSWYtweXfSRNQ@mail.gmail.com>
 <alpine.DEB.2.02.1310071256190.17658@dtop> <CAK6E8=d_O+HHTKb37zGKxpU8E0tTUL6m77g_o6a7ASEiJfXSkw@mail.gmail.com>
 <alpine.DEB.2.02.1310081123230.21359@dtop> <CAK6E8=d5VWMoOpDhZR4WaU6V6NJ9YSvJr=mm=rYNir0z644H=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e0158b30458d31a04e85248b3
Cc: Michele Baldessari <michele@acksyn.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:64781 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932371Ab3JIRd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:33:27 -0400
Received: by mail-ie0-f175.google.com with SMTP id aq17so2091617iec.20
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 10:33:26 -0700 (PDT)
In-Reply-To: <CAK6E8=d5VWMoOpDhZR4WaU6V6NJ9YSvJr=mm=rYNir0z644H=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e0158b30458d31a04e85248b3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 8, 2013 at 1:53 PM, Yuchung Cheng <ycheng@google.com> wrote:
>
> On Tue, Oct 8, 2013 at 11:24 AM, dormando <dormando@rydia.net> wrote:
> > On Mon, 7 Oct 2013, Yuchung Cheng wrote:
> >
> >> On Mon, Oct 7, 2013 at 12:56 PM, dormando <dormando@rydia.net> wrote:
> >> > On Mon, 7 Oct 2013, Yuchung Cheng wrote:
> >> >
> >> >> On Mon, Oct 7, 2013 at 11:13 AM, dormando <dormando@rydia.net> wrot=
e:
> >> >> >
> >> >> > > >
> >> >> > > > there's been multiple reports about this one:
> >> >> > > > https://bugzilla.redhat.com/show_bug.cgi?id=3D989251
> >> >> > > > http://bugzilla.kernel.org/show_bug.cgi?id=3D60779
> >> >> > > >
> >> >> > > > Could you try Yuchung's debug patch?
> >> >> > > > http://www.spinics.net/lists/netdev/msg250193.html
> >> >> > > Yes it looks like the same bug. Please try that patch to help i=
dentify
> >> >> > > this elusive bug.
> >> >> > >
> >> >> >
> >> >> > Hi!
> >> >> >
> >> >> > We get this one a few times a day in production. Here's a warning=
 with
> >> >> > your debug trace in the line immediately following:
> >> >> > (I censored a few things)
> >> >> >
> >> >> >  [125311.721950] ------------[ cut here ]------------
> >> >> >  [125311.721961] WARNING: at net/ipv4/tcp_input.c:2776 tcp_fastre=
trans_alert+0xb58/0xc80()
> >> >> >  [125311.721962] Modules linked in: bridge ip_vs macvlan coretemp=
 crc32_pclmul ghash_clmulni_intel gpio_ich ipmi_watchdog microcode ipmi_dev=
intf sb_edac lpc_ich edac_core mfd_core ipmi_si ipmi_msghandler iptable_nat=
 nf_nat_ipv4 nf_nat ixgbe igb mdio i2c_algo_bit ptp pps_core
> >> >> >  [125311.721981] CPU: 11 PID: 0 Comm: swapper/11 Not tainted 3.10=
.13 #1
> >> >> >  [125311.721982] Hardware name: Supermicro XXXXXXXXXXX, BIOS 1.1 =
10/03/2012
> >> >> >  [125311.721984]  ffffffff81a82007 ffff88407fc63958 ffffffff816bb=
9cc ffff88407fc63998
> >> >> >  [125311.721986]  ffffffff8104b940 00ff8840ad904f82 ffff883b8a165=
b00 0000000000004120
> >> >> >  [125311.721989]  0000000000000001 0000000000000019 0000000000000=
000 ffff88407fc639a8
> >> >> >  [125311.721991] Call Trace:
> >> >> >  [125311.721992]  <IRQ>  [<ffffffff816bb9cc>] dump_stack+0x19/0x1=
d
> >> >> >  [125311.722002]  [<ffffffff8104b940>] warn_slowpath_common+0x70/=
0xa0
> >> >> >  [125311.722005]  [<ffffffff8104b98a>] warn_slowpath_null+0x1a/0x=
20
> >> >> >  [125311.722007]  [<ffffffff81616db8>] tcp_fastretrans_alert+0xb5=
8/0xc80
> >> >> >  [125311.722011]  [<ffffffff8161891f>] tcp_ack+0x6df/0xe90
> >> >> >  [125311.722016]  [<ffffffff8164e0ca>] ? ipt_do_table+0x22a/0x680
> >> >> >  [125311.722018]  [<ffffffff816194b3>] ? tcp_validate_incoming+0x=
63/0x320
> >> >> >  [125311.722021]  [<ffffffff8161a55c>] tcp_rcv_established+0x2cc/=
0x810
> >> >> >  [125311.722023]  [<ffffffff81622c84>] tcp_v4_do_rcv+0x254/0x4f0
> >> >> >  [125311.722025]  [<ffffffff816245ac>] tcp_v4_rcv+0x5fc/0x750
> >> >> >  [125311.722027]  [<ffffffff815ffa00>] ? ip_rcv+0x350/0x350
> >> >> >  [125311.722032]  [<ffffffff815df3ad>] ? nf_hook_slow+0x7d/0x160
> >> >> >  [125311.722034]  [<ffffffff815ffa00>] ? ip_rcv+0x350/0x350
> >> >> >  [125311.722036]  [<ffffffff815fface>] ip_local_deliver_finish+0x=
ce/0x250
> >> >> >  [125311.722037]  [<ffffffff815ffc9c>] ip_local_deliver+0x4c/0x80
> >> >> >  [125311.722039]  [<ffffffff815ff329>] ip_rcv_finish+0x119/0x360
> >> >> >  [125311.722040]  [<ffffffff815ff8e0>] ip_rcv+0x230/0x350
> >> >> >  [125311.722046]  [<ffffffff815b4067>] __netif_receive_skb_core+0=
x477/0x600
> >> >> >  [125311.722049]  [<ffffffff815b4217>] __netif_receive_skb+0x27/0=
x70
> >> >> >  [125311.722051]  [<ffffffff815b4354>] process_backlog+0xf4/0x1e0
> >> >> >  [125311.722053]  [<ffffffff815b4b45>] net_rx_action+0xf5/0x250
> >> >> >  [125311.722056]  [<ffffffff81053a5f>] __do_softirq+0xef/0x270
> >> >> >  [125311.722058]  [<ffffffff81053cb5>] irq_exit+0x95/0xa0
> >> >> >  [125311.722062]  [<ffffffff816c8f26>] do_IRQ+0x66/0xe0
> >> >> >  [125311.722065]  [<ffffffff816bf62a>] common_interrupt+0x6a/0x6a
> >> >> >  [125311.722065]  <EOI>  [<ffffffff8100abf1>] ? default_idle+0x21=
/0xc0
> >> >> >  [125311.722082]  [<ffffffff8100a54f>] arch_cpu_idle+0xf/0x20
> >> >> >  [125311.722086]  [<ffffffff8108f353>] cpu_startup_entry+0xb3/0x2=
30
> >> >> >  [125311.722091]  [<ffffffff816b439e>] start_secondary+0x1dc/0x1e=
3
> >> >> >  [125311.722093] ---[ end trace e77cd5ba583fcbe9 ]---
> >> >> >  [125311.722096] 355.355.1.355:22496 F0x4120 S1 s7 IF25+17-1-24f0=
 ur57 rr3 rt0 um0 hs23120 nxt23120
> >> >> >
> >> >> > It's been happening with all 3.10 kernels, and the one above is .=
13 as
> >> >> > stated in the trace.
> >> >>
> >> >> Thanks! could you post the output of `sysctl -a |grep tcp`?
> >> >>
> >> >> I suspect tcp_process_tlp_ack() should not revert state to Open
> >> >> directly, but calling tcp_try_keep_open() instead, similar to all t=
he
> >> >> undo processing in the tcp_fastretrans_alert(): after
> >> >> tcp_end_cwnd_reduction(), the process (E) falls back to check other
> >> >> stats before moving to CA_Open.
> >> >>
> >> >>
> >> >> index 9c62257..9012b42 100644
> >> >> --- a/net/ipv4/tcp_input.c
> >> >> +++ b/net/ipv4/tcp_input.c
> >> >> @@ -3314,7 +3314,7 @@ static void tcp_process_tlp_ack(struct sock *=
sk, u32 ack,
> >> >>                         tcp_init_cwnd_reduction(sk, true);
> >> >>                         tcp_set_ca_state(sk, TCP_CA_CWR);
> >> >>                         tcp_end_cwnd_reduction(sk);
> >> >> -                       tcp_set_ca_state(sk, TCP_CA_Open);
> >> >> +                       tcp_try_keep_open(sk);
> >> >>                         NET_INC_STATS_BH(sock_net(sk),
> >> >>                                          LINUX_MIB_TCPLOSSPROBERECO=
VERY);
> >> >>                 }
> >> >>
> >> >
> >> > Should I apply this and see if the warning stops?
Hi Dormando,

Could you try this patch to make sure it fixes the warning (with
sysctl net.ipv4.early_retrans=3D3)?

> >> I'd like to hear what the authors of TLP think. In the mean time could
> >> you help us collect more evidence by disabling TLP with
> >> sysctl net.ipv4.tcp_early_retrans=3D2
> >> and see if the problem still occurs? (it should not).
> >>
> >> thanks
> >
> > Box hasn't had a warning in the last 24ish hours. A neighboring machine
> > with the default tcp_early_retrans setting has had 5-6 in the same
> > timeframe.
> >
> > Is this a harmful situation to the socket in any way, or is it just
> > informational weirdness?
> It should be fairly harmless. The ack that triggers the warning should
> set the TCP back to the good (non-Open) state, but it's still good to
> get rid of.

--089e0158b30458d31a04e85248b3
Content-Type: application/octet-stream;
	name="0001-tcp-fix-incorrect-ca_state-in-tail-loss-probe.patch"
Content-Disposition: attachment;
	filename="0001-tcp-fix-incorrect-ca_state-in-tail-loss-probe.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hmku3vva0

RnJvbSA2YWFjZmUyNDY5MjM0MWFjOTNjMWQxNTNhODAxYzM0MDY2Yjg2MjYyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBZdWNodW5nIENoZW5nIDx5Y2hlbmdAZ29vZ2xlLmNvbT4KRGF0
ZTogV2VkLCA5IE9jdCAyMDEzIDEwOjA4OjUyIC0wNzAwClN1YmplY3Q6IFtQQVRDSF0gdGNwOiBm
aXggaW5jb3JyZWN0IGNhX3N0YXRlIGluIHRhaWwgbG9zcyBwcm9iZQoKT24gcmVjZWl2aW5nIGFu
IEFDSyB0aGF0IGNvdmVycyB0aGUgbG9zcyBwcm9iZSBzZXF1ZW5jZSwgVExQCmltbWVkaWF0ZWx5
IHNldHMgdGhlIGNvbmdlc3Rpb24gc3RhdGUgdG8gT3BlbiwgZXZlbiB0aG91Z2ggc29tZSBwYWNr
ZXRzCmFyZSBub3QgcmVjb3ZlcmVkIGFuZCByZXRyYW5zbWlzc3Npb24gYXJlIG9uIHRoZSB3YXku
ICBUaGUgbGF0ZXIgQUNrcwptYXkgdHJpZ2dlciBhIFdBUk5fT04gY2hlY2sgb2Ygc3RlcCBEIGlu
IHRjcF9mYXN0cmV0cmFuc19hbGVydCgpLgoKVGhlIGZpeCBpcyB0byBmb2xsb3cgdGhlIHNpbWls
YXIgcHJvY2VkdXJlIGluIHJlY292ZXJ5IGJ5IGNhbGxpbmcKdGNwX3RyeV9rZWVwX29wZW4oKS4g
VGhlIHNlbmRlciBzd2l0Y2hlcyB0byBPcGVuIHN0YXRlIGlmIG5vIHBhY2tldHMKYXJlIHJldHJh
bnNtaXNzdGVkLiBPdGhlcndpc2UgaXQgZ29lcyB0byBEaXNvcmRlciBhbmQgbGV0IHN1YnNlcXVl
bnQKQUNLcyBtb3ZlIHRoZSBzdGF0ZSB0byBSZWNvdmVyeSBvciBPcGVuLgoKU2lnbmVkLW9mZi1i
eTogWXVjaHVuZyBDaGVuZyA8eWNoZW5nQGdvb2dsZS5jb20+Ci0tLQogbmV0L2lwdjQvdGNwX2lu
cHV0LmMgfCAyICstCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24o
LSkKCmRpZmYgLS1naXQgYS9uZXQvaXB2NC90Y3BfaW5wdXQuYyBiL25ldC9pcHY0L3RjcF9pbnB1
dC5jCmluZGV4IDExM2RjNWYuLjUzOTc0YzcgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L3RjcF9pbnB1
dC5jCisrKyBiL25ldC9pcHY0L3RjcF9pbnB1dC5jCkBAIC0zMjkxLDcgKzMyOTEsNyBAQCBzdGF0
aWMgdm9pZCB0Y3BfcHJvY2Vzc190bHBfYWNrKHN0cnVjdCBzb2NrICpzaywgdTMyIGFjaywgaW50
IGZsYWcpCiAJCQl0Y3BfaW5pdF9jd25kX3JlZHVjdGlvbihzaywgdHJ1ZSk7CiAJCQl0Y3Bfc2V0
X2NhX3N0YXRlKHNrLCBUQ1BfQ0FfQ1dSKTsKIAkJCXRjcF9lbmRfY3duZF9yZWR1Y3Rpb24oc2sp
OwotCQkJdGNwX3NldF9jYV9zdGF0ZShzaywgVENQX0NBX09wZW4pOworCQkJdGNwX3RyeV9rZWVw
X29wZW4oc2spOwogCQkJTkVUX0lOQ19TVEFUU19CSChzb2NrX25ldChzayksCiAJCQkJCSBMSU5V
WF9NSUJfVENQTE9TU1BST0JFUkVDT1ZFUlkpOwogCQl9Ci0tIAoxLjguNAoK
--089e0158b30458d31a04e85248b3--
