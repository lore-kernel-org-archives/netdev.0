From: Tyler Bautista <tylerbautista@gmail.com>
Subject: TC-pedit man page examples error
Date: Tue, 25 Jul 2017 08:33:40 -0700
Message-ID: <CAEPezq43wKM1ivHAUu6pFoGqz9+nCJ1FT9xQV702S_BCQvropA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:37986 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbdGYPdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 11:33:41 -0400
Received: by mail-pg0-f50.google.com with SMTP id k190so6141057pgk.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 08:33:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To whom it may concern,
I recently attempted to use simple tc action pedit commands on the man
page and I ran into some errors. The following is some information
about my version of iproute and my machine:
----------------------------
the following is my iproute package information

Loaded plugins: fastestmirror, langpacks
iproute-3.10.0-74.el7.x86_64
     changed_by = 0
     checksum_data =
f18d9a19e6531081a605086e5003422a87846854a10a306d122b59ff7bebb9d7
     checksum_type = sha256
     command_line = update
     from_repo = base
     from_repo_revision = 1480942829
     from_repo_timestamp = 1480942901
     installed_by = 4294967295
     origin_url =
http://mirror.confluxtech.com/centos/7/os/x86_64/Packages/iproute-3.10.0-74.el7.x86_64.rpm
     reason = user
     releasever = 7
     var_uuid = df8acb3e-a9df-4ffe-b95f-0311b19b2d33
---------------------------------------------------------------------------------
I am running the latest version of Centos 7 with kernel version:

3.10.0-514.26.2.el7.x86_64

-------------
The following are the first three commands of the man page that I run
and their output
---------------------------------------------------------------------------------

tc qdisc replace dev eth0 root handle 1: htb
tc qdisc add dev eth0 ingress handle ffff:
tc filter add dev eth0 parent 1: u32 \
>                    match ip dport 23 0xffff \
>                    action pedit pedit munge ip dport set 22
bad pedit parsing
Illegal pedit construct (ip)
Usage: ... pedit munge <MUNGE>
Where: MUNGE := <RAW>|<LAYERED>
<RAW>:= <OFFSETC>[ATC]<CMD>
  OFFSETC:= offset <offval> <u8|u16|u32>
  ATC:= at <atval> offmask <maskval> shift <shiftval>
  NOTE: offval is byte offset, must be multiple of 4
  NOTE: maskval is a 32 bit hex number
  NOTE: shiftval is a is a shift value
  CMD:= clear | invert | set <setval>| retain
  <LAYERED>:= ip <ipdata> | ip6 <ip6data>
  | udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>
For Example usage look at the examples directory
bad action parsing
parse_action: bad value (7:pedit)!
Illegal "action"
---------------------------------------------

The first two commands run without error. However the third command fails.

It apparently does not recognize the ip command. This seems strange to
me since the commands I run are on the tc-pedit man page. Any help on
this issue would be appreciated.
Sincerely,

Tyler Bautista
