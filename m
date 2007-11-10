From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 16:06:17 +0100
Message-ID: <4735C8E9.4030401@cosmosbay.com>
References: <20071110131428.GA6447@gondor.apana.org.au> <20071110.223243.114494952.yoshfuji@linux-ipv6.org> <20071110143325.GA6888@gondor.apana.org.au> <20071110.234854.10674315.yoshfuji@linux-ipv6.org> <20071110145536.GA7024@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:51777 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbXKJPGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 10:06:37 -0500
In-Reply-To: <20071110145536.GA7024@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu a =C3=A9crit :
> On Sat, Nov 10, 2007 at 11:48:54PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>> Hmm..... "netstat -s" from etch (i386) and etch (x86_64) work
>> fine for me.  Same version, same architecture.  Strange...
>=20
> Interesting.  What does your /proc/net/snmp file look like?
> And what does netstat -s actually produce?
>=20
> Thanks,

Quite easy :)

A failing one is > 1024 bytes :

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatag=
rams=20
InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRout=
es=20
ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreat=
es
Ip: 2 64 6954137412 0 23489 0 125 0 6790615249 6423886499 2706 0 13881=20
164999330 1503683 34165124 1219558 188 54871924
Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenc=
hs=20
InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks=
=20
InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmPr=
obs=20
OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps OutTimest=
ampReps=20
OutAddrMasks OutAddrMaskReps
Icmp: 6392743 1256162 3894707 401904 83 20702 172602 1415531 0 3 0 3 0=20
106773069 0 3894707 401904 83 20702 172602 1415531 0 3 0 3 0
IcmpMsg: InType3 InType4 InType5 InType8 InType11 InType12 InType13 InT=
ype17=20
OutType0 OutType3 OutType11 OutType14
IcmpMsg: 3894707 20702 172602 1415531 401904 83 3 3 1414557 105347007 1=
1502 3
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens Attemp=
tFails=20
EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 62967275 66063269 17969333 24912734 1278435 604183=
8336=20
5717892916 279078174 361708 35913131
Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufError=
s
Udp: 640604836 101598293 193394 421746699 133903 0
UdpLite: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufE=
rrors
UdpLite: 0 0 0 0 0 0


So netstat fails because line 344 in statistics.c :

buf1=3DTcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed Embryonic=
Rsts=20
PruneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFi=
lter TW=20
TWRecycled TWKilled PAWSPassive PAWSActive PAWSEstab DelayedACKs=20
DelayedACKLocked DelayedACKLost ListenOverflows ListenDrops TCPPrequeue=
d=20
TCPDirectCopyFromBacklog TCPDirectCopyFromPrequeue TCPPrequeueDropped=20
TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery=20
TCPSackRecovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoRe=
order=20
TCPTSReorder TCPFullUndo TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLos=
s=20
TCPLostRetransmit TCPRenoFailures TCPSackFailures TCPLossFailures=20
TCPFastRetrans TCPForwardRetrans TCPSlowStartRetrans TCPTimeouts=20
TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollap=
sed=20
TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbortOn=
Syn=20
TCPAbortOnData TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout=20
TCPAbortOnLinger TCPAbortFailed TCPMemoryPressures TCPSACKDiscard=20
TCPDSACKIgnoredOld TCPDSACKIgnoredNoUndo buf2=3D TCPSpuriousRTOs


So this is an existing kernel bug, not related to UDPlite
