From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: Regarding vxlan unicast configuration
Date: Tue, 17 May 2016 08:41:47 -0300
Message-ID: <20160517114147.GB13977@localhost.localdomain>
References: <CADAe=++oAXEuxOrJ0xw5VAvkre98SQa71vur6SjkyuWB4jg8xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbcEQLlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 07:41:50 -0400
Content-Disposition: inline
In-Reply-To: <CADAe=++oAXEuxOrJ0xw5VAvkre98SQa71vur6SjkyuWB4jg8xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, May 16, 2016 at 06:52:33PM -0700, Ajith Adapa wrote:
> Hi,
> 
> I am trying vxlan unicast configuration on a back to back connected
> interfaces of VM1 and VM2 running fedora 23 with 4.2 version of
> kernel. Below is my configuration
> 
> VM1
> 
> ip address add 100.1.1.1/24 dev enp0s8
> ifconfig enp0s8 up
> ip link add name vxlan42 type vxlan id 42 dev enp0s8 remote 50.1.1.2
> local 50.1.1.1 dstport 4789

Local and remote refers to the underlying interface actually, enp0s8 in
your case.

  Marcelo

> ip address add 50.1.1.1/24 dev vxlan42
> ip link set up vxlan42
> 
> VM2
> 
> ip address add 100.1.1.2/24 dev enp0s8
> ifconfig enp0s8 up
> ip link add name vxlan42 type vxlan id 42 dev enp0s8 remote 50.1.1.1
> local 50.1.1.2 dstport 4789
> ip address add 50.1.1.2/24 dev vxlan42
> ip link set up vxlan42
> 
> 
> Now when I try to ping 50.1.1.1 from VM2, I am receiving ARP packets
> on VM1 which are not vxlan tagged. As a result ping is not working.
> 
> I am able to successfully configure multicast based vxlan but having
> issues with vxlan unicast.
> 
> Is there something wrong with my configuration ?
> 
> Regards,
> Ajith
> 
