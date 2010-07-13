From: Ben Greear <greearb@candelatech.com>
Subject: iproute, batch-cmds, and mac-vlans.
Date: Mon, 12 Jul 2010 21:49:20 -0700
Message-ID: <4C3BF050.7040206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36832 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861Ab0GMEtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 00:49:22 -0400
Received: from [71.117.12.23] (pool-71-117-12-23.sttlwa.dsl-w.verizon.net [71.117.12.23])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o6D4nLJO032491
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 21:49:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After too much time debugging, I finally realized that the ip
tool was truncating my command because the mac-vlan device name
had a '#' in it.

]# cat /tmp/foo.txt
ru add to 10.99.21.1 iif eth0#0 lookup local pref 11


# IP tool has some hacked up debugging code
]# ip -batch /tmp/foo.txt
  argc: 4
  arg -:to:-
  arg -:iif:-
WARNING:  Using TABLE_MAIN in iprule_modify, table_ok: 0  cmd: 32


So, it acts on eth0 instead of eth0#0, and silently ignores the 'lookup local pref 11'.

I understand that it is trying to parse # as comments, but would you
all be interested in a patch that allowed ignoring '#' except
when it is the first non-whitespace character on a line, and maybe
when preceded by whitespace?  This would of course have the possibility
of breaking someone's script somewhere, so it could be enabled with
a new command line arg, perhaps.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
