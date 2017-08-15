From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Mellanox driver / cant access /prox/irq/XX/smp_affinity after upgrade
 from linux-4.13-rc4-next-20170811 to 4.13.0-rc5-next-20170815
Date: Tue, 15 Aug 2017 14:21:39 +0200
Message-ID: <357548fa-2987-4a90-1732-ad298384163e@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:54263 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751147AbdHOMWr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 08:22:47 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3xWs7T6PWbz3xCH
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 14:22:45 +0200 (CEST)
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


After upgrading kernel to latest next there is problem with accessing 
smp_affinity to write for mellanox driver

For example - MEllanox:

cat /proc/interrupts | grep ml
  217:          3          0          0          0 0          0          
0          0          0          0 0          0          0          
0          0          0 0          0          0          0          
0          0 0          0          0          0          0          0 
0          0          0          0          0          0 0          
0          0          0          0          0 0          0          
0          0          0          0 0          0          0          
0          0          0 0          0          0          0   PCI-MSI 
91750400-edge mlx5_pages_eq@pci:0000:af:00.0
  218:      12237          0          0          0 0          0          
0          0          0          0 0          0          0          
0          0          0 0          0          0          0          
0          0 0          0          0          0          0          0 
0          0          0          0          0          0 0          
0          0          0          0          0 0          0          
0          0          0          0 0          0          0          
0          0          0 0          0          0          0   PCI-MSI 
91750401-edge mlx5_cmd_eq@pci:0000:af:00.0

cat /proc/irq/218/smp_affinity
ffffff,ffffffff

echo  "ffffff,ffffffff " > /proc/irq/218/smp_affinity
-su: echo: write error: Input/output error


For intel ixgbe:

   90:          1          0          0          0 0          0          
0          0          0          0 0          0          0          
0          0          0 0          0          0          0          
0          0 0          0          0          0          0          0 
0          0          0          0          0          0 0          
0          0          0          0          0 0          0          
0          0          0          0 0          0          0          
0          0          0 0          0          0          0   PCI-MSI 
12589056-edge enp24s0f3

cat /proc/irq/90/smp_affinity
0003ff,f0003fff

  echo "0003ff,f0003fff" > /proc/irq/90/smp_affinity

Without errors.



BR

Pawel
