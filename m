From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2]  tc pedit   modify  ethhdr ?
Date: Wed, 24 Mar 2010 09:50:52 -0400
Message-ID: <1269438652.4089.22.camel@bigi>
References: <370745.69240.qm@web111619.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:56057 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755688Ab0CXNuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 09:50:52 -0400
Received: by pwi5 with SMTP id 5so3912949pwi.19
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 06:50:52 -0700 (PDT)
In-Reply-To: <370745.69240.qm@web111619.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-24 at 05:31 -0700, Xiaofei Wu wrote:

> but the size of ethhdr is 14 bytes, 14 is not multiple of 4 .
> How to use 'tc ... pedit ...'  modify  a packet's   h_dest and h_source 
> of ethhdr ?
> Use ' ... pedit munge offset -14 u16 set 0x0090 munge offset -12 u32 set 0x9600030a ... '   or 
> use ' ... pedit munge offset -16 u32 ... munge offset -12  ... '  ?
> 

0 is at ip header.
dst MAC starts at -14
src MAC at -8
ethertype at -2

Example:
tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match ip src 192.168.1.10/32 flowid 1:2 \
action pedit munge offset -14 u16 set 0x0000 \
munge offset -12 u32 set 0x00010100 \
munge offset -8 u32 set 0x0aaf0100 \
munge offset -4 u32 set 0x0008ec06 pipe \
action mirred egress redirect dev eth1

cheers,
jamal


