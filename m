From: "Ulrik De Bie" <ulrik.debie@newtec.eu>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Mon, 26 May 2008 14:11:04 +0200
Message-ID: <483AC4F80200008D00010946@mail.newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
To: "Kris Op de Beeck" <kris.op.de.beeck@newtec.eu>, <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Kris Op de Beeck wrote:
>> 
>>>>> On 22/05/2008 at 17:28, in message <4835913A.4020909@trash.net>, Patrick McHardy <kaber@trash.net> wrote:
>>>> [  927.204000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.30 DST=10.9.9.29 
>>> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=25745 DF PROTO=TCP SPT=52775 DPT=80 
>>> SEQ=2154890499 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
>>> (020405B40402080A000264810000000001030307) UID=1000
>>>> For those DST ip addresses I've got failures
>>> Which kernel is this test running on? That message
>>> is gone since 2.6.22.
>> 
>> s3p@burnin:~$ uname -a
>> Linux burnin 2.6.22-14-generic #1 SMP Sun Oct 14 23:05:12 GMT 2007 i686 GNU/Linux
>> 
>> This was the config where I detected the problem. (Ubuntu 7.10)

>I didn't find the reason why your kernel even has that message
>(didn't try to hard though). Could you rerun the test with a
>more current kernel, like 2.6.24 or 2.6.25 please?
Kris already provided you with the results for 2.6.24, behaviour there seems to have become even worse. 

But about your first remark:
The ubuntu 2.6.22-14 kernel has that message still, it's based on kernel version 2.6.22.9 and I downloaded the original from kernel.org, and that still contains the message:
linux-2.6.22.9/net/netfilter/nf_conntrack_proto_tcp.c at line 909 in function tcp_packet.

I also compared with the 2.6.17.1 (which is definitely older than the ubuntu 2.6.17), and the function tcp_packet has not changed between these versions. In 2.6.25 this function did have some changes though. So the relevant change causing the behaviour must be outside function tcp_packet.

Best regards,
Ulrik De Bie
Newtec will be present at the following exhibitions :

CommunicAsia, 17-20 June, Singapore, Booth 6B2-01

*** e-mail confidentiality footer ***
This message and any attachments thereto are confidential. They may also
be privileged or otherwise protected by work product immunity or other
legal rules. If you have received it by mistake, please let us know by
e-mail reply and delete it from your system; you may not copy this
message or disclose its contents to anyone.
E-mail transmission cannot be guaranteed to be secure or error free as
information could be intercepted, corrupted, lost, destroyed, arrive
late or incomplete, or contain viruses. The sender therefore is in no
way liable for any errors or omissions in the content of this message,
which may arise as a result of e-mail transmission. If verification is
required, please request a hard copy.

