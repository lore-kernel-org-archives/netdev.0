From: "Gautier Harmel" <Gautier.Harmel@qosmos.net>
Subject: TR : Bug with NIC card Adlink PCI 8214 (Intel 82559 based) under linux
Date: Thu, 26 Sep 2002 15:03:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003401c2655d$1ede6350$0d02a8c0@bananier>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <linux.nics@intel.com>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
 
I found bug using the Adlink PCI8214 nic card based on an Intel 82559
under Linux.
 
This bug occurs under a Linux 2.4.17 (e100 driver version 2.1.15 found
on the Intel web site) using the bridge functionality.
I didn't try using an earlier version of linux kernel.
 
I used LKCD (linux kernel crash debugger) to further investigate what
happens.
Here are my conclusions :
 
1)    the bug occurs in skb_checksum_help function (linux/net/core.dev.c
file)
2)       the disassembly code involved is:
     7c7:   0f 0b                   ud2a   
     7c9:   89 c8                   mov    %ecx,%eax
     7cb:   c1 e1 10                shl    $0x10,%ecx
     7ce:   25 00 00 ff ff          and    $0xffff0000,%eax
     7d3:   01 c8                   add    %ecx,%eax
     7d5:   15 ff ff 00 00          adc    $0xffff,%eax
     7da:   f7 d0                   not    %eax
     7dc:   c1 e8 10                shr    $0x10,%eax
     7df:   66 89 04 3e             mov    %ax,(%esi,%edi,1)
     7e3:   89 d8                   mov    %ebx,%eax
     7e5:   c6 43 6b 00             movb   $0x0,0x6b(%ebx)
 
3)    I think that this assembly code is the following line in
skb_checksum_help:
(*u16*)(skb->h.raw + skb->csum) = csum_fold(csum); (line 933)
 
 
Maybe skb->h.raw is a bad pointer ???
 
Thanks for help
 
Please CC me in your answer, while I didn't subscribe to any of the
mailing list
 
Jerome Tollet
Jerome.tollet@qosmos.net


[[HTML alternate version deleted]]
