From: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sun, 20 Feb 2005 23:06:20 GMT
Message-ID: <052MDIL12@server5.heliogroup.fr>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <shemminger@osdl.org>, romieu@fr.zoreil.com,
        kuznet@ms2.inr.ac.ru, niv@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Nivedita Singhvi<niv@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've noticed something very interesting:
if trying to send to a gigabit connected Mac OSX instead of 100 Mbps connected,
then there is no drastic slowdown when switching Linux 2.6.9 to 2.6.10


> Any chance you could
> send me just the following from your boxes:
> (Before and after the transfer)
>
> - /proc/net/snmp
> - /proc/net/netstat

Here are the requested extra informations:

2.6.10-ac10 before:

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 2 64 47336 0 0 0 0 0 47197 127721 0 0 0 0 0 0 0 0 0
Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenchs InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmProbs OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps OutTimestampReps OutAddrMasks OutAddrMaskReps
Icmp: 2 0 0 0 0 0 0 0 2 0 0 0 0 417 0 417 0 0 0 0 0 0 0 0 0 0
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 40 209 0 2 7 46158 126953 156 0 243
Udp: InDatagrams NoPorts InErrors OutDatagrams
Udp: 332 417 0 336

TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts PruneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFilter TW TWRecycled TWKilled PAWSPassive PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost ListenOverflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCopyFromPrequeue TCPPrequeueDropped TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSackRecovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder TCPTSReorder TCPFullUndo TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRenoFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRetrans TCPSlowStartRetrans TCPTimeouts TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollapsed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbortOnSyn TCPAbortOnData TCPAbortOnClose TCPAbortOnMemory T
 CPAbortOnTimeout TCPAbortOnLinger TCPAbortFailed TCPMemoryPressures
TcpExt: 0 0 0 0 0 0 0 0 0 0 94 0 0 0 0 0 452 0 0 0 0 9499 215 241030 0 7583 377 16696 3330 123 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 123 0 0 7 0 0 0 0 0 0 0 0 0 90 0 0 2 0 0 0

2.6.10-ac10 after sending to the 100 Mbps connected Mac OSX:

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 2 64 70100 0 0 0 0 0 69901 214176 0 0 0 0 0 0 0 0 0
Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenchs InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmProbs OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps OutTimestampReps OutAddrMasks OutAddrMaskReps
Icmp: 2 0 0 0 0 0 0 0 2 0 0 0 0 421 0 421 0 0 0 0 0 0 0 0 0 0
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 49 263 0 2 9 68728 213354 284 0 315
Udp: InDatagrams NoPorts InErrors OutDatagrams
Udp: 382 421 0 386

TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts PruneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFilter TW TWRecycled TWKilled PAWSPassive PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost ListenOverflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCopyFromPrequeue TCPPrequeueDropped TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSackRecovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder TCPTSReorder TCPFullUndo TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRenoFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRetrans TCPSlowStartRetrans TCPTimeouts TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollapsed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbortOnSyn TCPAbortOnData TCPAbortOnClose TCPAbortOnMemory T
 CPAbortOnTimeout TCPAbortOnLinger TCPAbortFailed TCPMemoryPressures
TcpExt: 0 0 0 0 0 0 0 0 0 0 105 0 0 0 0 0 804 0 0 0 0 12808 215 310763 0 11460 472 26236 5086 247 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 247 0 0 11 0 0 0 0 0 0 0 0 0 123 0 0 2 0 0 0
