From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Regarding vxlan unicast configuration
Date: Mon, 16 May 2016 18:52:33 -0700
Message-ID: <CADAe=++oAXEuxOrJ0xw5VAvkre98SQa71vur6SjkyuWB4jg8xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:34386 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755677AbcEQBxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 21:53:15 -0400
Received: by mail-vk0-f43.google.com with SMTP id c189so2487391vkb.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 18:53:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying vxlan unicast configuration on a back to back connected
interfaces of VM1 and VM2 running fedora 23 with 4.2 version of
kernel. Below is my configuration

VM1

ip address add 100.1.1.1/24 dev enp0s8
ifconfig enp0s8 up
ip link add name vxlan42 type vxlan id 42 dev enp0s8 remote 50.1.1.2
local 50.1.1.1 dstport 4789
ip address add 50.1.1.1/24 dev vxlan42
ip link set up vxlan42

VM2

ip address add 100.1.1.2/24 dev enp0s8
ifconfig enp0s8 up
ip link add name vxlan42 type vxlan id 42 dev enp0s8 remote 50.1.1.1
local 50.1.1.2 dstport 4789
ip address add 50.1.1.2/24 dev vxlan42
ip link set up vxlan42


Now when I try to ping 50.1.1.1 from VM2, I am receiving ARP packets
on VM1 which are not vxlan tagged. As a result ping is not working.

I am able to successfully configure multicast based vxlan but having
issues with vxlan unicast.

Is there something wrong with my configuration ?

Regards,
Ajith
