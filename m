From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out
Date: Wed, 16 Jun 2004 11:59:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D0280B.2030308@dgreaves.com>
References: <40CDD68C.8070509@dgreaves.com> <20040615155111.26d6b809@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040615155111.26d6b809@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>How big is the transmit ring. Setting a bigger transmit ring fixed my problem
>	modprobe e1000 TxDescriptors=1024
>
>Also, there are lots of flavors of this chipset and board.  One machine
>I was using had the IBM rebranded version and it would only do PCI33 not PCI66.
>
>  
>
Thanks for replying Stephen - it's really frustrating :)

I did try TxDescriptors and various (most) other parameters (below are 
the actual parameter variations I tried - just cut from a 'history' for 
info).

After each one i downed the link and modprobe -r the driver.
I then ran a large file scp (quicker id+recovery than nfs hanging when 
the link died)

I invariably got an eth0 timed out after a few seconds - some variation 
but IIRC no more than 20% - ie 8-10Mb of a 1G file before it failed.

root@ash:~ # ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:             4096
RX Mini:        0
RX Jumbo:       0
TX:             4096
Current hardware settings:
RX:             256
RX Mini:        0
RX Jumbo:       0
TX:             1024

I've pulled all the cards and looked - they are all genuine Intel 
C39226-003 (Pro/1000 MT)
This page http://support.intel.com/support/network/sb/cs-005980-prd38.htm
says: 82541 Gigabit Small Form 32/66
My system has PCI33 BTW.

I have also tried 2.6.7 this morning and have the same problem.

David


module parameters.
modprobe e1000 FlowControl=2
modprobe e1000 FlowControl=1
modprobe e1000 FlowControl=3
modprobe e1000 FlowControl=0
modprobe e1000 FlowControl=0 InterruptThrottleRate=100
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=1024 
; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=4096 
; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=1  ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=10  ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=1000  ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=0  ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=0 TxIntDelay=0 ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=1024 TxIntDelay=53 ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=1024 TxIntDelay=64 ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=65535 TxIntDelay=64 ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=128 TxIntDelay=0 ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=128 TxIntDelay=32000 ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=128 TxIntDelay=32000 ; ifup eth0
modprobe e1000 FlowControl=0 InterruptThrottleRate=1 RxDescriptors=256 
RxIntDelay=0 RxAbsIntDelay=128 TxIntDelay=64 XsumRX=1 ; ifup eth0
modprobe e1000 Speed=100
modprobe e1000 Speed=10
